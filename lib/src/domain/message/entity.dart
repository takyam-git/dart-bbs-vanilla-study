part of app.domain;

class MessageEntity extends DomainEntity {
  MessageEntity(String author, String body): super._({
      "author": author.isNotEmpty ? author : "名無し",
      "body": body,
  });
}