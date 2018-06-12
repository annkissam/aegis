# v 0.2.0
* Bumps Elixir version to 1.6
* Renames method: `Aegis.authorize/3` --> `Aegis.authorized?/3`
* Removes `scope/3` callback from `Aegis.Policy` behaviour
* Adds flexibility to the way that policies are found via the ability to specify a policy finder via a `policy_finder` configuration
* Adds `Aegis.DefaultPolicyFinder` module for default policy-finding
* Removes all method implementation logic from `Aegis.PolicyFinder` (moved to `Aegis.DefaultPolicyFinder`), and defines only a callback specification for `call/1`
* Shifts to raising Aegis-specific error (`Aegis.PolicyNotFoundError`) when the configured policy finder fails to determine a policy.
* Improves upon existing documentation.
* Bug Squashed: the method signature of `Aegis.Controller.authorized?/4` to return value that's consistent with authorization having been performed on the `Plug.Conn`. Before this, when the authorization check failed, this method returned `{:error, :not_authorized}` without passing the connection struct, thereby losing information as to whether or not authorization had been performed at all (via checking the value of the `conn.private[:aegis_auth_performed]`.

# v 0.1.1
* Remove warning when :except is empty (on Aegis.Controller)

# v 0.1.0
* Initial Release
