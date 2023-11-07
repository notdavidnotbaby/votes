// The 'votes.leo' program.
program votes.aleo {


    struct Title {
        data0: u128,
        data1: u128,
        data2: u128,
        data3: u128,
    }

    struct Description {
        data0: u128,
        data1: u128,
        data2: u128,
        data3: u128,
    }

    // Proposal details
    struct DetailedProposal {
        title: Title,
        desc: Description,
        content: field,
        proposer: address,
    }

    record Proposal {
        owner: address,
        id: field,
        info: DetailedProposal,
    }

    mapping proposals: field => DetailedProposal;

    // Privacy tickets to vote
    record VotingTicket {
        owner: address,
        pid: field,
    }

    // Count the total tickets issued for each proposal
    mapping tickets: field => u64;

    mapping agree_votes: field => u64;

    mapping disagree_votes: field => u64;

    // Propose a new proposal to vote on.
    transition propose(public info: DetailedProposal) -> Proposal {
        // Authenticate proposer.
        assert_eq(self.caller, info.proposer);

        // Generate a new proposal id.
        let id: field = BHP256::hash_to_field(info.title);


        // Return a new record for the proposal.
        // Finalize the proposal id.
        return Proposal {
            owner: self.caller,
            id,
            info,
        } then finalize(id);
    }
    // Create a new proposal in the "tickets" mapping.
    finalize propose(public id: field) {
        Mapping::set(tickets, id, 0u64);
    }

    transition register_proposal(
        public pid: field,
        public voter: address,
    ) -> VotingTicket {

        // Finalize the proposal id for the ticket.
        return VotingTicket {
            owner: voter,
            pid,
        } then finalize(pid);
    }
    finalize register_proposal(public pid: field) {
        let current: u64 = Mapping::get_or_use(tickets, pid, 0u64);
        Mapping::set(tickets, pid, current + 1u64);
    }

    transition agree(ticket: VotingTicket) {
        // Finalize this vote.
        return then finalize(ticket.pid);
    }
    finalize agree(public pid: field) {
        // Publicly increment the number of agree votes.
        let current: u64 = Mapping::get_or_use(agree_votes, pid, 0u64);
        Mapping::set(agree_votes, pid, current + 1u64);
    }

    transition disagree(ticket: VotingTicket) {
        // Finalize this vote.
        return then finalize(ticket.pid);
    }
    finalize disagree(pid: field) {
        // Publicly increment the number of disagree votes.
        let current: u64 = Mapping::get_or_use(disagree_votes, pid, 0u64);
        Mapping::set(disagree_votes, pid, current + 1u64);
    }
}