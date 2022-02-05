## Pull Request Checklist for Reviewer

- [ ] Is the code valid?
- [ ] Does the change "do no harm"-- does not break anything if taken alone?
- [ ] Is data migrated correctly? E.g.:
  - Are suitable defaults and initial values set for new columns?
  - Is data from any removed or changed column handled appropriately (e.g. moved to a different location, or converted to the column's new type)?
  - Can the migrations be run against the production database without any data loss?
  - Are any migrations reversible? If a migration is run and then reversed, is any data lost?
- [ ] Is there appropriate authentication & authorization logic (permissions)?
- [ ] Are there tests?

- [ ] Do the changes make use of existing code appropriately? (For example, existing react components or rails controllers/models. Could be via composition, extension or changes to the existing components/class).
- [ ] Were examples added for code that is intended to/likely to be reused? (via Rev.appExample in the case of JS code, or doc block comments in the case of Rails code)

- [ ] Is there appropriate documentation for the changes? (At least set up instructions for any new dependencies or third party integrations)
- [ ] Does the code match our style guides for the language (i.e. lints are addressed)?
- [ ] Are there appropriate comments?

- [ ] If change introduces annotations like HACK, TODO or FIXME, has a plan been established for fixing the HACK/FIXME in a timely manner. Have appropriate follow-up issues been logged?

- [ ] For PRs that introduce front-end changes-- are there desktop and mobile screenshots attached?
