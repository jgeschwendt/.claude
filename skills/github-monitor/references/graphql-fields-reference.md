# GitHub GraphQL: complete field reference for PR & review monitoring

**Auto-generated from GitHub's official machine-readable schema**
(`octokit/graphql-schema`), so this is the full field surface — nothing
hand-picked. Both of this skill's queries are programmatically validated
against this same schema at generation time.

Legend: ✓ = field currently used by this skill's scripts. ⚠ = deprecated.
Connection-typed fields (`…Connection`) take pagination args
(`first/after`); drill into them with nested selections.

## Contents
- [PullRequest](#pullrequest)
- [PullRequestReview](#pullrequestreview)
- [PullRequestReviewThread](#pullrequestreviewthread)
- [PullRequestReviewComment](#pullrequestreviewcomment)
- [IssueComment](#issuecomment)
- [ReviewRequest](#reviewrequest)
- [StatusCheckRollup](#statuscheckrollup)
- [CheckRun](#checkrun)
- [StatusContext](#statuscontext)
- [Issue](#issue)
- [Enums](#enums)

## PullRequest

A repository pull request.

Implements: Assignable, Closable, Comment, Labelable, Lockable, Node, ProjectV2Owner, Reactable, RepositoryNode, Subscribable, UniformResourceLocatable, Updatable, UpdatableComment

| | Field | Type | Description |
|---|---|---|---|
|  | `activeLockReason` | `LockReason` | Reason that the conversation was locked. |
| ✓ | `additions` | `Int!` | The number of additions in this pull request. |
|  | `assignees` | `UserConnection!` | A list of Users assigned to this object. |
| ✓ | `author` | `Actor` | The actor who authored the comment. |
|  | `authorAssociation` | `CommentAuthorAssociation!` | Author's association with the subject of the comment. |
|  | `autoMergeRequest` | `AutoMergeRequest` | Returns the auto-merge request object if one exists for this pull request. |
|  | `baseRef` | `Ref` | Identifies the base Ref associated with the pull request. |
|  | `baseRefName` | `String!` | Identifies the name of the base Ref associated with the pull request, even if the ref has been deleted. |
|  | `baseRefOid` | `GitObjectID!` | Identifies the oid of the base ref associated with the pull request, even if the ref has been deleted. |
|  | `baseRepository` | `Repository` | The repository associated with this pull request's base Ref. |
|  | `body` | `String!` | The body as Markdown. |
|  | `bodyHTML` | `HTML!` | The body rendered to HTML. |
|  | `bodyText` | `String!` | The body rendered to text. |
|  | `canBeRebased` | `Boolean!` | Whether or not the pull request is rebaseable. |
| ✓ | `changedFiles` | `Int!` | The number of changed files in this pull request. |
|  | `checksResourcePath` | `URI!` | The HTTP path for the checks of this pull request. |
|  | `checksUrl` | `URI!` | The HTTP URL for the checks of this pull request. |
|  | `closed` | `Boolean!` | `true` if the pull request is closed |
|  | `closedAt` | `DateTime` | Identifies the date and time when the object was closed. |
|  | `closingIssuesReferences` | `IssueConnection` | List of issues that may be closed by this pull request |
|  | `comments` | `IssueCommentConnection!` | A list of comments associated with the pull request. |
| ✓ | `commits` | `PullRequestCommitConnection!` | A list of commits present in this pull request's head branch not present in the base branch. |
|  | `createdAt` | `DateTime!` | Identifies the date and time when the object was created. |
|  | `createdViaEmail` | `Boolean!` | Check if this comment was created via an email reply. |
| ⚠ | `databaseId` | `Int` | **Deprecated:** `databaseId` will be removed because it does not support 64-bit signed integer identifiers. Identifies the primary key from the database. |
| ✓ | `deletions` | `Int!` | The number of deletions in this pull request. |
|  | `editor` | `Actor` | The actor who edited this pull request's body. |
|  | `files` | `PullRequestChangedFileConnection` | Lists the files changed within this pull request. |
|  | `fullDatabaseId` | `BigInt` | Identifies the primary key from the database as a BigInt. |
|  | `headRef` | `Ref` | Identifies the head Ref associated with the pull request. |
|  | `headRefName` | `String!` | Identifies the name of the head Ref associated with the pull request, even if the ref has been deleted. |
|  | `headRefOid` | `GitObjectID!` | Identifies the oid of the head ref associated with the pull request, even if the ref has been deleted. |
|  | `headRepository` | `Repository` | The repository associated with this pull request's head Ref. |
|  | `headRepositoryOwner` | `RepositoryOwner` | The owner of the repository associated with this pull request's head Ref. |
|  | `hovercard` | `Hovercard!` | The hovercard information for this issue |
|  | `id` | `ID!` | The Node ID of the PullRequest object |
|  | `includesCreatedEdit` | `Boolean!` | Check if this comment was edited and includes an edit with the creation data |
|  | `isCrossRepository` | `Boolean!` | The head and base repositories are different. |
| ✓ | `isDraft` | `Boolean!` | Identifies if the pull request is a draft. |
|  | `isInMergeQueue` | `Boolean!` | Indicates whether the pull request is in a merge queue |
|  | `isMergeQueueEnabled` | `Boolean!` | Indicates whether the pull request's base ref has a merge queue enabled. |
|  | `isReadByViewer` | `Boolean` | Is this pull request read by the viewer |
|  | `labels` | `LabelConnection` | A list of labels associated with the object. |
|  | `lastEditedAt` | `DateTime` | The moment the editor made the last edit |
|  | `latestOpinionatedReviews` | `PullRequestReviewConnection` | A list of latest reviews per user associated with the pull request. |
|  | `latestReviews` | `PullRequestReviewConnection` | A list of latest reviews per user associated with the pull request that are not also pending review. |
|  | `locked` | `Boolean!` | `true` if the pull request is locked |
|  | `maintainerCanModify` | `Boolean!` | Indicates whether maintainers can modify the pull request. |
|  | `mergeCommit` | `Commit` | The commit that was created when this pull request was merged. |
|  | `mergeQueue` | `MergeQueue` | The merge queue for the pull request's base branch |
|  | `mergeQueueEntry` | `MergeQueueEntry` | The merge queue entry of the pull request in the base branch's merge queue |
|  | `mergeStateStatus` | `MergeStateStatus!` | Detailed information about the current pull request merge state status. |
| ✓ | `mergeable` | `MergeableState!` | Whether or not the pull request can be merged based on the existence of merge conflicts. |
|  | `merged` | `Boolean!` | Whether or not the pull request was merged. |
|  | `mergedAt` | `DateTime` | The date and time that the pull request was merged. |
|  | `mergedBy` | `Actor` | The actor who merged the pull request. |
|  | `milestone` | `Milestone` | Identifies the milestone associated with the pull request. |
| ✓ | `number` | `Int!` | Identifies the pull request number. |
|  | `participants` | `UserConnection!` | A list of Users that are participating in the Pull Request conversation. |
|  | `permalink` | `URI!` | The permalink to the pull request. |
|  | `potentialMergeCommit` | `Commit` | The commit that GitHub automatically generated to test if this pull request could be merged. |
|  | `projectCards` | `ProjectCardConnection!` | List of project cards associated with this pull request. |
|  | `projectItems` | `ProjectV2ItemConnection!` | List of project items associated with this pull request. |
|  | `projectV2` | `ProjectV2` | Find a project by number. |
|  | `projectsV2` | `ProjectV2Connection!` | A list of projects under the owner. |
|  | `publishedAt` | `DateTime` | Identifies when the comment was published at. |
|  | `reactionGroups` | `[ReactionGroup!]` | A list of reactions grouped by content left on the subject. |
|  | `reactions` | `ReactionConnection!` | A list of Reactions left on the Issue. |
| ✓ | `repository` | `Repository!` | The repository associated with this node. |
|  | `resourcePath` | `URI!` | The HTTP path for this pull request. |
|  | `revertResourcePath` | `URI!` | The HTTP path for reverting this pull request. |
|  | `revertUrl` | `URI!` | The HTTP URL for reverting this pull request. |
| ✓ | `reviewDecision` | `PullRequestReviewDecision` | The current status of this pull request with respect to code review. |
| ✓ | `reviewRequests` | `ReviewRequestConnection` | A list of review requests associated with the pull request. |
| ✓ | `reviewThreads` | `PullRequestReviewThreadConnection!` | The list of all review threads for this pull request. |
| ✓ | `reviews` | `PullRequestReviewConnection` | A list of reviews associated with the pull request. |
|  | `state` | `PullRequestState!` | Identifies the state of the pull request. |
|  | `statusCheckRollup` | `StatusCheckRollup` | Check and Status rollup information for the PR's head ref. |
|  | `suggestedReviewers` | `[SuggestedReviewer]!` | A list of reviewer suggestions based on commit history and past review comments. |
| ⚠ | `timeline` | `PullRequestTimelineConnection!` | **Deprecated:** `timeline` will be removed Use PullRequest.timelineItems instead. A list of events, comments, commits, etc. |
|  | `timelineItems` | `PullRequestTimelineItemsConnection!` | A list of events, comments, commits, etc. |
| ✓ | `title` | `String!` | Identifies the pull request title. |
|  | `titleHTML` | `HTML!` | Identifies the pull request title rendered to HTML. |
|  | `totalCommentsCount` | `Int` | Returns a count of how many comments this pull request has received. |
| ✓ | `updatedAt` | `DateTime!` | Identifies the date and time when the object was last updated. |
| ✓ | `url` | `URI!` | The HTTP URL for this pull request. |
|  | `userContentEdits` | `UserContentEditConnection` | A list of edits to this content. |
|  | `viewerCanApplySuggestion` | `Boolean!` | Whether or not the viewer can apply suggestion. |
|  | `viewerCanClose` | `Boolean!` | Indicates if the object can be closed by the viewer. |
|  | `viewerCanDeleteHeadRef` | `Boolean!` | Check if the viewer can restore the deleted head ref. |
|  | `viewerCanDisableAutoMerge` | `Boolean!` | Whether or not the viewer can disable auto-merge |
|  | `viewerCanEditFiles` | `Boolean!` | Can the viewer edit files within this pull request. |
|  | `viewerCanEnableAutoMerge` | `Boolean!` | Whether or not the viewer can enable auto-merge |
|  | `viewerCanLabel` | `Boolean!` | Indicates if the viewer can edit labels for this object. |
|  | `viewerCanMergeAsAdmin` | `Boolean!` | Indicates whether the viewer can bypass branch protections and merge the pull request immediately |
|  | `viewerCanReact` | `Boolean!` | Can user react to this subject |
|  | `viewerCanReopen` | `Boolean!` | Indicates if the object can be reopened by the viewer. |
|  | `viewerCanSubscribe` | `Boolean!` | Check if the viewer is able to change their subscription status for the repository. |
|  | `viewerCanUpdate` | `Boolean!` | Check if the current viewer can update this object. |
|  | `viewerCanUpdateBranch` | `Boolean!` | Whether or not the viewer can update the head ref of this PR, by merging or rebasing the base ref. |
|  | `viewerCannotUpdateReasons` | `[CommentCannotUpdateReason!]!` | Reasons why the current viewer can not update this comment. |
|  | `viewerDidAuthor` | `Boolean!` | Did the viewer author this comment. |
|  | `viewerLatestReview` | `PullRequestReview` | The latest review given from the viewer. |
|  | `viewerLatestReviewRequest` | `ReviewRequest` | The person who has requested the viewer for review on this pull request. |
|  | `viewerMergeBodyText` | `String!` | The merge body text for the viewer and method. |
|  | `viewerMergeHeadlineText` | `String!` | The merge headline text for the viewer and method. |
|  | `viewerSubscription` | `SubscriptionState` | Identifies if the viewer is watching, not watching, or ignoring the subscribable entity. |

## PullRequestReview

A review object for a given pull request.

Implements: Comment, Deletable, Minimizable, Node, Reactable, RepositoryNode, Updatable, UpdatableComment

| | Field | Type | Description |
|---|---|---|---|
| ✓ | `author` | `Actor` | The actor who authored the comment. |
|  | `authorAssociation` | `CommentAuthorAssociation!` | Author's association with the subject of the comment. |
|  | `authorCanPushToRepository` | `Boolean!` | Indicates whether the author of this review has push access to the repository. |
| ✓ | `body` | `String!` | Identifies the pull request review body. |
|  | `bodyHTML` | `HTML!` | The body rendered to HTML. |
|  | `bodyText` | `String!` | The body of this review rendered as plain text. |
|  | `comments` | `PullRequestReviewCommentConnection!` | A list of review comments for the current pull request review. |
|  | `commit` | `Commit` | Identifies the commit associated with this pull request review. |
|  | `createdAt` | `DateTime!` | Identifies the date and time when the object was created. |
|  | `createdViaEmail` | `Boolean!` | Check if this comment was created via an email reply. |
| ⚠ | `databaseId` | `Int` | **Deprecated:** `databaseId` will be removed because it does not support 64-bit signed integer identifiers. Identifies the primary key from the database. |
|  | `editor` | `Actor` | The actor who edited the comment. |
|  | `fullDatabaseId` | `BigInt` | Identifies the primary key from the database as a BigInt. |
|  | `id` | `ID!` | The Node ID of the PullRequestReview object |
|  | `includesCreatedEdit` | `Boolean!` | Check if this comment was edited and includes an edit with the creation data |
|  | `isMinimized` | `Boolean!` | Returns whether or not a comment has been minimized. |
|  | `lastEditedAt` | `DateTime` | The moment the editor made the last edit |
|  | `minimizedReason` | `String` | Returns why the comment was minimized. |
|  | `onBehalfOf` | `TeamConnection!` | A list of teams that this review was made on behalf of. |
|  | `publishedAt` | `DateTime` | Identifies when the comment was published at. |
|  | `pullRequest` | `PullRequest!` | Identifies the pull request associated with this pull request review. |
|  | `reactionGroups` | `[ReactionGroup!]` | A list of reactions grouped by content left on the subject. |
|  | `reactions` | `ReactionConnection!` | A list of Reactions left on the Issue. |
|  | `repository` | `Repository!` | The repository associated with this node. |
|  | `resourcePath` | `URI!` | The HTTP path permalink for this PullRequestReview. |
| ✓ | `state` | `PullRequestReviewState!` | Identifies the current state of the pull request review. |
| ✓ | `submittedAt` | `DateTime` | Identifies when the Pull Request Review was submitted |
|  | `updatedAt` | `DateTime!` | Identifies the date and time when the object was last updated. |
|  | `url` | `URI!` | The HTTP URL permalink for this PullRequestReview. |
|  | `userContentEdits` | `UserContentEditConnection` | A list of edits to this content. |
|  | `viewerCanDelete` | `Boolean!` | Check if the current viewer can delete this object. |
|  | `viewerCanMinimize` | `Boolean!` | Check if the current viewer can minimize this object. |
|  | `viewerCanReact` | `Boolean!` | Can user react to this subject |
|  | `viewerCanUpdate` | `Boolean!` | Check if the current viewer can update this object. |
|  | `viewerCannotUpdateReasons` | `[CommentCannotUpdateReason!]!` | Reasons why the current viewer can not update this comment. |
|  | `viewerDidAuthor` | `Boolean!` | Did the viewer author this comment. |

## PullRequestReviewThread

A threaded list of comments for a given pull request.

Implements: Node

| | Field | Type | Description |
|---|---|---|---|
| ✓ | `comments` | `PullRequestReviewCommentConnection!` | A list of pull request comments associated with the thread. |
|  | `diffSide` | `DiffSide!` | The side of the diff on which this thread was placed. |
|  | `id` | `ID!` | The Node ID of the PullRequestReviewThread object |
|  | `isCollapsed` | `Boolean!` | Whether or not the thread has been collapsed (resolved) |
| ✓ | `isOutdated` | `Boolean!` | Indicates whether this thread was outdated by newer changes. |
| ✓ | `isResolved` | `Boolean!` | Whether this thread has been resolved |
| ✓ | `line` | `Int` | The line in the file to which this thread refers |
|  | `originalLine` | `Int` | The original line in the file to which this thread refers. |
|  | `originalStartLine` | `Int` | The original start line in the file to which this thread refers (multi-line only). |
| ✓ | `path` | `String!` | Identifies the file path of this thread. |
|  | `pullRequest` | `PullRequest!` | Identifies the pull request associated with this thread. |
|  | `repository` | `Repository!` | Identifies the repository associated with this thread. |
| ✓ | `resolvedBy` | `User` | The user who resolved this thread |
|  | `startDiffSide` | `DiffSide` | The side of the diff that the first line of the thread starts on (multi-line only) |
| ✓ | `startLine` | `Int` | The start line in the file to which this thread refers (multi-line only) |
| ✓ | `subjectType` | `PullRequestReviewThreadSubjectType!` | The level at which the comments in the corresponding thread are targeted, can be a diff line or a file |
|  | `viewerCanReply` | `Boolean!` | Indicates whether the current viewer can reply to this thread. |
|  | `viewerCanResolve` | `Boolean!` | Whether or not the viewer can resolve this thread |
|  | `viewerCanUnresolve` | `Boolean!` | Whether or not the viewer can unresolve this thread |

## PullRequestReviewComment

A review comment associated with a given repository pull request.

Implements: Comment, Deletable, Minimizable, Node, Reactable, RepositoryNode, Updatable, UpdatableComment

| | Field | Type | Description |
|---|---|---|---|
| ✓ | `author` | `Actor` | The actor who authored the comment. |
|  | `authorAssociation` | `CommentAuthorAssociation!` | Author's association with the subject of the comment. |
| ✓ | `body` | `String!` | The comment body of this review comment. |
|  | `bodyHTML` | `HTML!` | The body rendered to HTML. |
|  | `bodyText` | `String!` | The comment body of this review comment rendered as plain text. |
|  | `commit` | `Commit` | Identifies the commit associated with the comment. |
| ✓ | `createdAt` | `DateTime!` | Identifies when the comment was created. |
|  | `createdViaEmail` | `Boolean!` | Check if this comment was created via an email reply. |
| ⚠ | `databaseId` | `Int` | **Deprecated:** `databaseId` will be removed because it does not support 64-bit signed integer identifiers. Identifies the primary key from the database. |
|  | `diffHunk` | `String!` | The diff hunk to which the comment applies. |
|  | `draftedAt` | `DateTime!` | Identifies when the comment was created in a draft state. |
|  | `editor` | `Actor` | The actor who edited the comment. |
|  | `fullDatabaseId` | `BigInt` | Identifies the primary key from the database as a BigInt. |
|  | `id` | `ID!` | The Node ID of the PullRequestReviewComment object |
|  | `includesCreatedEdit` | `Boolean!` | Check if this comment was edited and includes an edit with the creation data |
| ✓ | `isMinimized` | `Boolean!` | Returns whether or not a comment has been minimized. |
|  | `lastEditedAt` | `DateTime` | The moment the editor made the last edit |
|  | `line` | `Int` | The end line number on the file to which the comment applies |
|  | `minimizedReason` | `String` | Returns why the comment was minimized. |
|  | `originalCommit` | `Commit` | Identifies the original commit associated with the comment. |
|  | `originalLine` | `Int` | The end line number on the file to which the comment applied when it was first created |
| ⚠ | `originalPosition` | `Int!` | **Deprecated:** We are phasing out diff-relative positioning for PR comments Removal on 2023-10-01 UTC. The original line index in the diff to which the comment applies. |
|  | `originalStartLine` | `Int` | The start line number on the file to which the comment applied when it was first created |
|  | `outdated` | `Boolean!` | Identifies when the comment body is outdated |
|  | `path` | `String!` | The path to which the comment applies. |
| ⚠ | `position` | `Int` | **Deprecated:** We are phasing out diff-relative positioning for PR comments Use the `line` and `startLine` fields instead, which are file line numbers instead of di… The line index in the diff to which the comment applies. |
|  | `publishedAt` | `DateTime` | Identifies when the comment was published at. |
|  | `pullRequest` | `PullRequest!` | The pull request associated with this review comment. |
|  | `pullRequestReview` | `PullRequestReview` | The pull request review associated with this review comment. |
|  | `reactionGroups` | `[ReactionGroup!]` | A list of reactions grouped by content left on the subject. |
|  | `reactions` | `ReactionConnection!` | A list of Reactions left on the Issue. |
|  | `replyTo` | `PullRequestReviewComment` | The comment this is a reply to. |
|  | `repository` | `Repository!` | The repository associated with this node. |
|  | `resourcePath` | `URI!` | The HTTP path permalink for this review comment. |
|  | `startLine` | `Int` | The start line number on the file to which the comment applies |
|  | `state` | `PullRequestReviewCommentState!` | Identifies the state of the comment. |
|  | `subjectType` | `PullRequestReviewThreadSubjectType!` | The level at which the comments in the corresponding thread are targeted, can be a diff line or a file |
|  | `updatedAt` | `DateTime!` | Identifies when the comment was last updated. |
|  | `url` | `URI!` | The HTTP URL permalink for this review comment. |
|  | `userContentEdits` | `UserContentEditConnection` | A list of edits to this content. |
|  | `viewerCanDelete` | `Boolean!` | Check if the current viewer can delete this object. |
|  | `viewerCanMinimize` | `Boolean!` | Check if the current viewer can minimize this object. |
|  | `viewerCanReact` | `Boolean!` | Can user react to this subject |
|  | `viewerCanUpdate` | `Boolean!` | Check if the current viewer can update this object. |
|  | `viewerCannotUpdateReasons` | `[CommentCannotUpdateReason!]!` | Reasons why the current viewer can not update this comment. |
|  | `viewerDidAuthor` | `Boolean!` | Did the viewer author this comment. |

## IssueComment

Represents a comment on an Issue.

Implements: Comment, Deletable, Minimizable, Node, Reactable, RepositoryNode, Updatable, UpdatableComment

| | Field | Type | Description |
|---|---|---|---|
|  | `author` | `Actor` | The actor who authored the comment. |
|  | `authorAssociation` | `CommentAuthorAssociation!` | Author's association with the subject of the comment. |
|  | `body` | `String!` | The body as Markdown. |
|  | `bodyHTML` | `HTML!` | The body rendered to HTML. |
|  | `bodyText` | `String!` | The body rendered to text. |
|  | `createdAt` | `DateTime!` | Identifies the date and time when the object was created. |
|  | `createdViaEmail` | `Boolean!` | Check if this comment was created via an email reply. |
|  | `databaseId` | `Int` | Identifies the primary key from the database. |
|  | `editor` | `Actor` | The actor who edited the comment. |
|  | `fullDatabaseId` | `BigInt` | Identifies the primary key from the database as a BigInt. |
|  | `id` | `ID!` | The Node ID of the IssueComment object |
|  | `includesCreatedEdit` | `Boolean!` | Check if this comment was edited and includes an edit with the creation data |
|  | `isMinimized` | `Boolean!` | Returns whether or not a comment has been minimized. |
|  | `issue` | `Issue!` | Identifies the issue associated with the comment. |
|  | `lastEditedAt` | `DateTime` | The moment the editor made the last edit |
|  | `minimizedReason` | `String` | Returns why the comment was minimized. |
|  | `publishedAt` | `DateTime` | Identifies when the comment was published at. |
|  | `pullRequest` | `PullRequest` | Returns the pull request associated with the comment, if this comment was made on a pull request. |
|  | `reactionGroups` | `[ReactionGroup!]` | A list of reactions grouped by content left on the subject. |
|  | `reactions` | `ReactionConnection!` | A list of Reactions left on the Issue. |
|  | `repository` | `Repository!` | The repository associated with this node. |
|  | `resourcePath` | `URI!` | The HTTP path for this issue comment |
|  | `updatedAt` | `DateTime!` | Identifies the date and time when the object was last updated. |
|  | `url` | `URI!` | The HTTP URL for this issue comment |
|  | `userContentEdits` | `UserContentEditConnection` | A list of edits to this content. |
|  | `viewerCanDelete` | `Boolean!` | Check if the current viewer can delete this object. |
|  | `viewerCanMinimize` | `Boolean!` | Check if the current viewer can minimize this object. |
|  | `viewerCanReact` | `Boolean!` | Can user react to this subject |
|  | `viewerCanUpdate` | `Boolean!` | Check if the current viewer can update this object. |
|  | `viewerCannotUpdateReasons` | `[CommentCannotUpdateReason!]!` | Reasons why the current viewer can not update this comment. |
|  | `viewerDidAuthor` | `Boolean!` | Did the viewer author this comment. |

## ReviewRequest

A request for a user to review a pull request.

Implements: Node

| | Field | Type | Description |
|---|---|---|---|
|  | `asCodeOwner` | `Boolean!` | Whether this request was created for a code owner |
|  | `databaseId` | `Int` | Identifies the primary key from the database. |
|  | `id` | `ID!` | The Node ID of the ReviewRequest object |
|  | `pullRequest` | `PullRequest!` | Identifies the pull request associated with this review request. |
| ✓ | `requestedReviewer` | `RequestedReviewer` | The reviewer that is requested. |

## StatusCheckRollup

Represents the rollup for both the check runs and status for a commit.

Implements: Node

| | Field | Type | Description |
|---|---|---|---|
|  | `commit` | `Commit` | The commit the status and check runs are attached to. |
|  | `contexts` | `StatusCheckRollupContextConnection!` | A list of status contexts and check runs for this commit. |
|  | `id` | `ID!` | The Node ID of the StatusCheckRollup object |
| ✓ | `state` | `StatusState!` | The combined status for the commit. |

## CheckRun

A check run.

Implements: Node, RequirableByPullRequest, UniformResourceLocatable

| | Field | Type | Description |
|---|---|---|---|
|  | `annotations` | `CheckAnnotationConnection` | The check run's annotations |
|  | `checkSuite` | `CheckSuite!` | The check suite that this run is a part of. |
|  | `completedAt` | `DateTime` | Identifies the date and time when the check run was completed. |
|  | `conclusion` | `CheckConclusionState` | The conclusion of the check run. |
|  | `databaseId` | `Int` | Identifies the primary key from the database. |
|  | `deployment` | `Deployment` | The corresponding deployment for this job, if any |
|  | `detailsUrl` | `URI` | The URL from which to find full details of the check run on the integrator's site. |
|  | `externalId` | `String` | A reference for the check run on the integrator's system. |
|  | `id` | `ID!` | The Node ID of the CheckRun object |
|  | `isRequired` | `Boolean!` | Whether this is required to pass before merging for a specific pull request. |
|  | `name` | `String!` | The name of the check for this check run. |
|  | `pendingDeploymentRequest` | `DeploymentRequest` | Information about a pending deployment, if any, in this check run |
|  | `permalink` | `URI!` | The permalink to the check run summary. |
|  | `repository` | `Repository!` | The repository associated with this check run. |
|  | `resourcePath` | `URI!` | The HTTP path for this check run. |
|  | `startedAt` | `DateTime` | Identifies the date and time when the check run was started. |
|  | `status` | `CheckStatusState!` | The current status of the check run. |
|  | `steps` | `CheckStepConnection` | The check run's steps |
|  | `summary` | `String` | A string representing the check run's summary |
|  | `text` | `String` | A string representing the check run's text |
|  | `title` | `String` | A string representing the check run |
|  | `url` | `URI!` | The HTTP URL for this check run. |

## StatusContext

Represents an individual commit status context

Implements: Node, RequirableByPullRequest

| | Field | Type | Description |
|---|---|---|---|
|  | `avatarUrl` | `URI` | The avatar of the OAuth application or the user that created the status |
|  | `commit` | `Commit` | This commit this status context is attached to. |
|  | `context` | `String!` | The name of this status context. |
|  | `createdAt` | `DateTime!` | Identifies the date and time when the object was created. |
|  | `creator` | `Actor` | The actor who created this status context. |
|  | `description` | `String` | The description for this status context. |
|  | `id` | `ID!` | The Node ID of the StatusContext object |
|  | `isRequired` | `Boolean!` | Whether this is required to pass before merging for a specific pull request. |
|  | `state` | `StatusState!` | The state of this status context. |
|  | `targetUrl` | `URI` | The URL for this status context. |

## Issue

An Issue is a place to discuss ideas, enhancements, tasks, and bugs for a project.

Implements: Assignable, Closable, Comment, Deletable, Labelable, Lockable, Node, ProjectV2Owner, Reactable, RepositoryNode, Subscribable, SubscribableThread, UniformResourceLocatable, Updatable, UpdatableComment

| | Field | Type | Description |
|---|---|---|---|
|  | `activeLockReason` | `LockReason` | Reason that the conversation was locked. |
|  | `assignees` | `UserConnection!` | A list of Users assigned to this object. |
|  | `author` | `Actor` | The actor who authored the comment. |
|  | `authorAssociation` | `CommentAuthorAssociation!` | Author's association with the subject of the comment. |
|  | `body` | `String!` | Identifies the body of the issue. |
|  | `bodyHTML` | `HTML!` | The body rendered to HTML. |
|  | `bodyResourcePath` | `URI!` | The http path for this issue body |
|  | `bodyText` | `String!` | Identifies the body of the issue rendered to text. |
|  | `bodyUrl` | `URI!` | The http URL for this issue body |
|  | `closed` | `Boolean!` | Indicates if the object is closed (definition of closed may depend on type) |
|  | `closedAt` | `DateTime` | Identifies the date and time when the object was closed. |
|  | `closedByPullRequestsReferences` | `PullRequestConnection` | List of open pull requests referenced from this issue |
|  | `comments` | `IssueCommentConnection!` | A list of comments associated with the Issue. |
|  | `createdAt` | `DateTime!` | Identifies the date and time when the object was created. |
|  | `createdViaEmail` | `Boolean!` | Check if this comment was created via an email reply. |
|  | `databaseId` | `Int` | Identifies the primary key from the database. |
|  | `editor` | `Actor` | The actor who edited the comment. |
|  | `fullDatabaseId` | `BigInt` | Identifies the primary key from the database as a BigInt. |
|  | `hovercard` | `Hovercard!` | The hovercard information for this issue |
|  | `id` | `ID!` | The Node ID of the Issue object |
|  | `includesCreatedEdit` | `Boolean!` | Check if this comment was edited and includes an edit with the creation data |
|  | `isPinned` | `Boolean` | Indicates whether or not this issue is currently pinned to the repository issues list |
|  | `isReadByViewer` | `Boolean` | Is this issue read by the viewer |
|  | `labels` | `LabelConnection` | A list of labels associated with the object. |
|  | `lastEditedAt` | `DateTime` | The moment the editor made the last edit |
|  | `linkedBranches` | `LinkedBranchConnection!` | Branches linked to this issue. |
|  | `locked` | `Boolean!` | `true` if the object is locked |
|  | `milestone` | `Milestone` | Identifies the milestone associated with the issue. |
| ✓ | `number` | `Int!` | Identifies the issue number. |
|  | `parent` | `Issue` | The parent entity of the issue. |
|  | `participants` | `UserConnection!` | A list of Users that are participating in the Issue conversation. |
|  | `projectCards` | `ProjectCardConnection!` | List of project cards associated with this issue. |
|  | `projectItems` | `ProjectV2ItemConnection!` | List of project items associated with this issue. |
|  | `projectV2` | `ProjectV2` | Find a project by number. |
|  | `projectsV2` | `ProjectV2Connection!` | A list of projects under the owner. |
|  | `publishedAt` | `DateTime` | Identifies when the comment was published at. |
|  | `reactionGroups` | `[ReactionGroup!]` | A list of reactions grouped by content left on the subject. |
|  | `reactions` | `ReactionConnection!` | A list of Reactions left on the Issue. |
| ✓ | `repository` | `Repository!` | The repository associated with this node. |
|  | `resourcePath` | `URI!` | The HTTP path for this issue |
|  | `state` | `IssueState!` | Identifies the state of the issue. |
|  | `stateReason` | `IssueStateReason` | Identifies the reason for the issue state. |
|  | `subIssues` | `IssueConnection!` | A list of sub-issues associated with the Issue. |
|  | `subIssuesSummary` | `SubIssuesSummary!` | Summary of the state of an issue's sub-issues |
| ⚠ | `timeline` | `IssueTimelineConnection!` | **Deprecated:** `timeline` will be removed Use Issue.timelineItems instead. A list of events, comments, commits, etc. |
|  | `timelineItems` | `IssueTimelineItemsConnection!` | A list of events, comments, commits, etc. |
| ✓ | `title` | `String!` | Identifies the issue title. |
|  | `titleHTML` | `String!` | Identifies the issue title rendered to HTML. |
|  | `trackedInIssues` | `IssueConnection!` | A list of issues that track this issue |
|  | `trackedIssues` | `IssueConnection!` | A list of issues tracked inside the current issue |
|  | `trackedIssuesCount` | `Int!` | The number of tracked issues for this issue |
| ✓ | `updatedAt` | `DateTime!` | Identifies the date and time when the object was last updated. |
| ✓ | `url` | `URI!` | The HTTP URL for this issue |
|  | `userContentEdits` | `UserContentEditConnection` | A list of edits to this content. |
|  | `viewerCanClose` | `Boolean!` | Indicates if the object can be closed by the viewer. |
|  | `viewerCanDelete` | `Boolean!` | Check if the current viewer can delete this object. |
|  | `viewerCanLabel` | `Boolean!` | Indicates if the viewer can edit labels for this object. |
|  | `viewerCanReact` | `Boolean!` | Can user react to this subject |
|  | `viewerCanReopen` | `Boolean!` | Indicates if the object can be reopened by the viewer. |
|  | `viewerCanSubscribe` | `Boolean!` | Check if the viewer is able to change their subscription status for the repository. |
|  | `viewerCanUpdate` | `Boolean!` | Check if the current viewer can update this object. |
|  | `viewerCannotUpdateReasons` | `[CommentCannotUpdateReason!]!` | Reasons why the current viewer can not update this comment. |
|  | `viewerDidAuthor` | `Boolean!` | Did the viewer author this comment. |
|  | `viewerSubscription` | `SubscriptionState` | Identifies if the viewer is watching, not watching, or ignoring the subscribable entity. |
|  | `viewerThreadSubscriptionFormAction` | `ThreadSubscriptionFormAction` | Identifies the viewer's thread subscription form action. |
|  | `viewerThreadSubscriptionStatus` | `ThreadSubscriptionState` | Identifies the viewer's thread subscription status. |

## Enums

### PullRequestState
The possible states of a pull request.

`CLOSED` (A pull request that has been closed without being merged); `MERGED` (A pull request that has been closed by being merged); `OPEN` (A pull request that is still open)

### PullRequestReviewState
The possible states of a pull request review.

`APPROVED` (A review allowing the pull request to merge); `CHANGES_REQUESTED` (A review blocking the pull request from merging); `COMMENTED` (An informational review); `DISMISSED` (A review that has been dismissed); `PENDING` (A review that has not yet been submitted)

### PullRequestReviewDecision
The review status of a pull request.

`APPROVED` (The pull request has received an approving review); `CHANGES_REQUESTED` (Changes have been requested on the pull request); `REVIEW_REQUIRED` (A review is required before the pull request can be merged)

### MergeableState
Whether or not a PullRequest can be merged.

`CONFLICTING` (The pull request cannot be merged due to merge conflicts); `MERGEABLE` (The pull request can be merged); `UNKNOWN` (The mergeability of the pull request is still being calculated)

### MergeStateStatus
Detailed status information about a pull request merge.

`BEHIND` (The head ref is out of date); `BLOCKED` (The merge is blocked); `CLEAN` (Mergeable and passing commit status); `DIRTY` (The merge commit cannot be cleanly created); `DRAFT` (The merge is blocked due to the pull request being a draft); `HAS_HOOKS` (Mergeable with passing commit status and pre-receive hooks); `UNKNOWN` (The state cannot currently be determined); `UNSTABLE` (Mergeable with non-passing commit status)

### StatusState
The possible commit status states.

`ERROR` (Status is errored); `EXPECTED` (Status is expected); `FAILURE` (Status is failing); `PENDING` (Status is pending); `SUCCESS` (Status is successful)

### CheckStatusState
The possible states for a check suite or run status.

`COMPLETED` (The check suite or run has been completed); `IN_PROGRESS` (The check suite or run is in progress); `PENDING` (The check suite or run is in pending state); `QUEUED` (The check suite or run has been queued); `REQUESTED` (The check suite or run has been requested); `WAITING` (The check suite or run is in waiting state)

### CheckConclusionState
The possible states for a check suite or run conclusion.

`ACTION_REQUIRED` (The check suite or run requires action); `CANCELLED` (The check suite or run has been cancelled); `FAILURE` (The check suite or run has failed); `NEUTRAL` (The check suite or run was neutral); `SKIPPED` (The check suite or run was skipped); `STALE` (The check suite or run was marked stale by GitHub); `STARTUP_FAILURE` (The check suite or run has failed at startup); `SUCCESS` (The check suite or run has succeeded); `TIMED_OUT` (The check suite or run has timed out)

### PullRequestReviewThreadSubjectType
The possible subject types of a pull request review comment.

`FILE` (A comment that has been made against the file of a pull request); `LINE` (A comment that has been made against the line of a pull request)

### CommentAuthorAssociation
A comment author association with repository.

`COLLABORATOR` (Author has been invited to collaborate on the repository); `CONTRIBUTOR` (Author has previously committed to the repository); `FIRST_TIMER` (Author has not previously committed to GitHub); `FIRST_TIME_CONTRIBUTOR` (Author has not previously committed to the repository); `MANNEQUIN` (Author is a placeholder for an unclaimed user); `MEMBER` (Author is a member of the organization that owns the repository); `NONE` (Author has no association with the repository); `OWNER` (Author is the owner of the repository)

### DiffSide
The possible sides of a diff.

`LEFT` (The left side of the diff); `RIGHT` (The right side of the diff)

### PullRequestReviewCommentState
The possible states of a pull request review comment.

`PENDING` (A comment that is part of a pending review); `SUBMITTED` (A comment that is part of a submitted review)

## Union: StatusCheckRollupContext

Members: CheckRun, StatusContext — each check in a rollup is one of these; use inline fragments.

