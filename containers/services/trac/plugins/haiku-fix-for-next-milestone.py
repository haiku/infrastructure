#
# Revision log:
# 4 August 2020: initial version
# 1 October 2023: fix for python 3: dict.itervalues() -> dict.values()
#
from trac.core import Component, implements
from trac.ticket import ITicketActionController, ConfigurableTicketWorkflow
from trac.ticket.model import MilestoneCache


class HaikuFixForNextMilestone(Component):
    """Add ticket action to close as 'fixed' for the next milestone.

    The underlying policy is that if a ticket is closed as 'fixed', the
    milestone should be set to the release that will contain the
    improvement.

    This plugin makes this policy easier for developers to adhere to, as it
    will add a few custom resolution actions. It will still be possible for a
    user to diverge from the policy and choose their own milestone.
    """

    implements(ITicketActionController)

    def get_ticket_actions(self, req, ticket):
        controller = ConfigurableTicketWorkflow(self.env)
        actions = controller.get_actions_by_operation_for_req(req, ticket, 'fix_for_next_milestone')
        if len(actions) > 0 and self._get_next_milestone() is not None:
            return[(1, 'fix_for_next_milestone')]
        return []

    def get_all_status(self):
        return []

    def render_ticket_action_control(self, req, ticket, action):
        if action == "fix_for_next_milestone":
            milestone = self._get_next_milestone()
            return ('resolve as fixed', 'for milestone %s' % milestone,
                'The resolution will be set to fixed. Next status will be \'closed\'.')
        return '', '', ''

    def get_ticket_changes(self, req, ticket, action):
        if action == "fix_for_next_milestone":
            return {
                'resolution': 'fixed',
                'status': 'closed',
                'milestone': self._get_next_milestone()
            }
        return {}

    def apply_action_side_effects(self, req, ticket, action):
        pass

    def _get_next_milestone(self):
        milestone = None
        current_due = None
        for name, due, completed, description in MilestoneCache(self.env).milestones.values():
            if due is not None and completed is None:
                if current_due is None or current_due > due:
                    milestone = name
                    current_due = due
        return milestone

