import SwiftUI
import OSLog

@Observable final class PartyHandler {
    var parties: [PartyAttributes] = []
    var partyInvites: [PartyAttributes] = []
    var selectedPartyDetails: PartyDetails?
    var isLoadingParties = false
    var isLoadingInvites = false
    var isLoadingDetails = false
    var isCreatingParty = false
    var isEditingParty = false
    var isDeletingParty = false
    var isLeavingParty = false
    var isJoiningParty = false
    var isInvitingUser = false
    var isRemovingUser = false
    var isRevokingInvite = false
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
                case .failure(let error):
                    self?.errorMessage = "Failed to load party invites"
                    Logger.partyHandler.error("Error fetching party invites: \(error)")
                }
            }
        }
    }

    func fetchPartyDetails(partyId: String, sortBy: LeaderboardSort = .verticalDistance, timeframe: Timeframe = .season, completion: ((Bool) -> Void)? = nil) {
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
                    completion?(true)
                case .failure(let error):
                    self?.errorMessage = "Failed to load party details"
                    Logger.partyHandler.error("Error fetching party details: \(error)")
                    completion?(false)
                }
            }
        }
    }

    func createParty(name: String, description: String? = nil, completion: @escaping (Bool) -> Void) {
        isCreatingParty = true
        errorMessage = nil

        ApolloLynxClient.createParty(name: name, description: description) { [weak self] result in
            DispatchQueue.main.async {
                self?.isCreatingParty = false
                switch result {
                case .success(let newParty):
                    self?.parties.append(newParty)
                    completion(true)
                case .failure(let error):
                    self?.errorMessage = "Failed to create party"
                    Logger.partyHandler.error("Error creating party: \(error)")
                    completion(false)
                }
            }
        }
    }

    func editParty(partyId: String, name: String, description: String?, completion: @escaping (Bool) -> Void) {
        isEditingParty = true
        errorMessage = nil

        var changes: [String: String] = ["name": name]
        if let description = description {
            changes["description"] = description
        }

        ApolloLynxClient.editParty(partyId: partyId, partyChanges: changes) { [weak self] result in
            DispatchQueue.main.async {
                self?.isEditingParty = false
                switch result {
                case .success(let editedParty):
                    if let currentDetails = self?.selectedPartyDetails {
                        self?.selectedPartyDetails = PartyDetails(
                            id: editedParty.id,
                            name: editedParty.name,
                            description: editedParty.description,
                            partyManager: editedParty.partyManager,
                            users: editedParty.users,
                            invitedUsers: editedParty.invitedUsers,
                            leaderboard: currentDetails.leaderboard
                        )
                    }
                    completion(true)
                case .failure(let error):
                    self?.errorMessage = "Failed to edit party"
                    Logger.partyHandler.error("Error editing party: \(error)")
                    completion(false)
                }
            }
        }
    }

    func deleteParty(partyId: String, completion: @escaping (Bool) -> Void) {
        isDeletingParty = true
        errorMessage = nil

        ApolloLynxClient.deleteParty(partyId: partyId) { [weak self] result in
            DispatchQueue.main.async {
                self?.isDeletingParty = false
                switch result {
                case .success:
                    self?.parties.removeAll { $0.id == partyId }
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
        isJoiningParty = true
        errorMessage = nil

        ApolloLynxClient.joinParty(partyId: partyId) { [weak self] result in
            DispatchQueue.main.async {
                self?.isJoiningParty = false
                switch result {
                case .success:
                    self?.partyInvites.removeAll { $0.id == partyId }
                    self?.fetchParties()
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
        isLeavingParty = true
        errorMessage = nil

        ApolloLynxClient.leaveParty(partyId: partyId) { [weak self] result in
            DispatchQueue.main.async {
                self?.isLeavingParty = false
                switch result {
                case .success:
                    self?.parties.removeAll { $0.id == partyId }
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
        isInvitingUser = true
        errorMessage = nil

        ApolloLynxClient.inviteUserToParty(partyId: partyId, userId: userId) { [weak self] result in
            DispatchQueue.main.async {
                self?.isInvitingUser = false
                switch result {
                case .success(let inviteResult):
                    if let currentDetails = self?.selectedPartyDetails {
                        self?.selectedPartyDetails = PartyDetails(
                            id: currentDetails.id,
                            name: currentDetails.name,
                            description: currentDetails.description,
                            partyManager: currentDetails.partyManager,
                            users: currentDetails.users,
                            invitedUsers: inviteResult.invitedUsers,
                            leaderboard: currentDetails.leaderboard
                        )
                    }
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
        isRemovingUser = true
        errorMessage = nil

        ApolloLynxClient.removeUserFromParty(partyId: partyId, userId: userId) { [weak self] result in
            DispatchQueue.main.async {
                self?.isRemovingUser = false
                switch result {
                case .success(let removeResult):
                    if let currentDetails = self?.selectedPartyDetails {
                        self?.selectedPartyDetails = PartyDetails(
                            id: currentDetails.id,
                            name: currentDetails.name,
                            description: currentDetails.description,
                            partyManager: currentDetails.partyManager,
                            users: removeResult.users,
                            invitedUsers: currentDetails.invitedUsers,
                            leaderboard: currentDetails.leaderboard
                        )
                    }
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
        isRevokingInvite = true
        errorMessage = nil

        ApolloLynxClient.removeInviteFromParty(partyId: partyId, userId: userId) { [weak self] result in
            DispatchQueue.main.async {
                self?.isRevokingInvite = false
                switch result {
                case .success(let removeResult):
                    if let currentDetails = self?.selectedPartyDetails {
                        self?.selectedPartyDetails = PartyDetails(
                            id: currentDetails.id,
                            name: currentDetails.name,
                            description: currentDetails.description,
                            partyManager: currentDetails.partyManager,
                            users: currentDetails.users,
                            invitedUsers: removeResult.invitedUsers,
                            leaderboard: currentDetails.leaderboard
                        )
                    }
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
