/// Participant role enum representing the different roles in a conference.
/// 
/// This is a domain entity and must remain framework-agnostic.
/// No Flutter, Dio, or other framework imports should be added.
enum ParticipantRole {
  host,
  moderator,
  member,
  guest,
}
