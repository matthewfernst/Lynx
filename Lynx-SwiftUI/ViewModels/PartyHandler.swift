import SwiftUI
import OSLog

@Observable final class PartyHandler {
    var parties: [PartyAttributes] = []
    var partyInvites: [PartyAttributes] = []
    var selectedPartyDetails: PartyDetails?
    var isLoadingParties = false
    var isLoadingInvites = false
    var isLoadingDetails = false
    var errorMessage: String?

    func fetchParties() {
        isLoadingParties = true
        errorMessage = nil

        ApolloLynxClient.getParties { [weak self] result in
            DispatchQueue.main.async {
                self?.isLoadingParties = false
                switch result {
                case .success(let fetchedParties):
                    self?.parties = fetchedParties
                    Logger.partyHandler.info("Successfully fetched \(fetchedParties.count) parties")
                case .failure(let error):
                    self?.errorMessage = "Failed to load parties"
                    Logger.partyHandler.error("Error fetching parties: \(error)")
                }
            }
        }
    }

    func fetchPartyInvites() {
        isLoadingInvites = true
        errorMessage = nil

        ApolloLynxClient.getPartyInvites { [weak self] result in
            DispatchQueue.main.async {
                self?.isLoadingInvites = false
                switch result {
                case .success(let fetchedInvites):
                    self?.partyInvites = fetchedInvites
                    Logger.partyHandler.info("Successfully fetched \(fetchedInvites.count) party invites")
                case .failure(let error):
                    self?.errorMessage = "Failed to load party invites"
                    Logger.partyHandler.error("Error fetching party invites: \(error)")
                }
            }
        }
    }

    func fetchPartyDetails(partyId: String, sortBy: LeaderboardSort = .verticalDistance, timeframe: Timeframe = .season) {
        isLoadingDetails = true
        errorMessage = nil

        ApolloLynxClient.getPartyDetails(
            partyId: partyId,
            sortBy: sortBy,
            timeframe: timeframe
        ) { [weak self] result in
            DispatchQueue.main.async {
                self?.isLoadingDetails = false
                switch result {
                case .success(let details):
                    self?.selectedPartyDetails = details
                    Logger.partyHandler.info("Successfully fetched party details for \(partyId)")
                case .failure(let error):
                    self?.errorMessage = "Failed to load party details"
                    Logger.partyHandler.error("Error fetching party details: \(error)")
                }
            }
        }
    }

    func createParty(name: String, completion: @escaping (Bool) -> Void) {
        errorMessage = nil

        ApolloLynxClient.createParty(name: name) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let newParty):
                    self?.parties.append(newParty)
                    Logger.partyHandler.info("Successfully created party: \(name)")
                    completion(true)
                case .failure(let error):
                    self?.errorMessage = "Failed to create party"
                    Logger.partyHandler.error("Error creating party: \(error)")
                    completion(false)
                }
            }
        }
    }

    func deleteParty(partyId: String, completion: @escaping (Bool) -> Void) {
        errorMessage = nil

        ApolloLynxClient.deleteParty(partyId: partyId) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success:
                    self?.parties.removeAll { $0.id == partyId }
                    Logger.partyHandler.info("Successfully deleted party: \(partyId)")
                    completion(true)
                case .failure(let error):
                    self?.errorMessage = "Failed to delete party"
                    Logger.partyHandler.error("Error deleting party: \(error)")
                    completion(false)
                }
            }
        }
    }

    func joinParty(partyId: String, completion: @escaping (Bool) -> Void) {
        errorMessage = nil

        ApolloLynxClient.joinParty(partyId: partyId) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success:
                    self?.partyInvites.removeAll { $0.id == partyId }
                    self?.fetchParties()
                    Logger.partyHandler.info("Successfully joined party: \(partyId)")
                    completion(true)
                case .failure(let error):
                    self?.errorMessage = "Failed to join party"
                    Logger.partyHandler.error("Error joining party: \(error)")
                    completion(false)
                }
            }
        }
    }

    func leaveParty(partyId: String, completion: @escaping (Bool) -> Void) {
        errorMessage = nil

        ApolloLynxClient.leaveParty(partyId: partyId) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success:
                    self?.parties.removeAll { $0.id == partyId }
                    Logger.partyHandler.info("Successfully left party: \(partyId)")
                    completion(true)
                case .failure(let error):
                    self?.errorMessage = "Failed to leave party"
                    Logger.partyHandler.error("Error leaving party: \(error)")
                    completion(false)
                }
            }
        }
    }

    func inviteUserToParty(partyId: String, userId: String, completion: @escaping (Result<Void, Error>) -> Void) {
        errorMessage = nil

        ApolloLynxClient.inviteUserToParty(partyId: partyId, userId: userId) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success:
                    self?.fetchPartyDetails(partyId: partyId)
                    Logger.partyHandler.info("Successfully invited user to party")
                    completion(.success(()))
                case .failure(let error):
                    self?.errorMessage = "Failed to invite user"
                    Logger.partyHandler.error("Error inviting user: \(error)")
                    completion(.failure(error))
                }
            }
        }
    }

    func removeUserFromParty(partyId: String, userId: String, completion: @escaping (Bool) -> Void) {
        errorMessage = nil

        ApolloLynxClient.removeUserFromParty(partyId: partyId, userId: userId) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success:
                    self?.fetchPartyDetails(partyId: partyId)
                    Logger.partyHandler.info("Successfully removed user from party")
                    completion(true)
                case .failure(let error):
                    self?.errorMessage = "Failed to remove user"
                    Logger.partyHandler.error("Error removing user: \(error)")
                    completion(false)
                }
            }
        }
    }

    func revokePartyInvite(partyId: String, userId: String, completion: @escaping (Bool) -> Void) {
        errorMessage = nil

        ApolloLynxClient.removeInviteFromParty(partyId: partyId, userId: userId) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success:
                    self?.fetchPartyDetails(partyId: partyId)
                    Logger.partyHandler.info("Successfully revoked party invite")
                    completion(true)
                case .failure(let error):
                    self?.errorMessage = "Failed to revoke invite"
                    Logger.partyHandler.error("Error revoking invite: \(error)")
                    completion(false)
                }
            }
        }
    }

    func refreshAll() {
        fetchParties()
        fetchPartyInvites()
    }
}

extension Logger {
    static let partyHandler = Logger(subsystem: "com.lynx", category: "PartyHandler")
}
