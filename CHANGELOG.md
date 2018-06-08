# v 0.2.0
* Bumps Elixir version to 1.6
* Renames method: `Aegis.authorize/3` --> `Aegis.authorized?/3`
* Removes `scope/3` callback from `Aegis.Policy` behaviour
* Adds flexibility to the way that policies are found via the ability to specify a policy finder via a `policy_finder` configuration
* Adds `Aegis.DefaultPolicyFinder` module for default policy-finding
* Removes all method implementation logic from `Aegis.PolicyFinder` (moved to `Aegis.DefaultPolicyFinder`), and defines only a callback specification for `call/1`
* Shifts to raising Aegis-specific error (`Aegis.PolicyNotFoundError`) when the configured policy finder fails to determine a policy.
* Improves upon existing documentation.

# v 0.1.1
* Remove warning when :except is empty (on Aegis.Controller)

# v 0.1.0
* Initial Release
