/* 
  Model for comment 
  * message - the message user commented
  * userUd - user document id
  * postId - post document id
  * createdAt - DateTime formated (yyyy - mm -dd) converted to a string
*/

class Comment {
  final String message;
  final String userId;
  final String postId;
  final String createdAt;

  Comment({
    required this.message,
    required this.userId,
    required this.postId,
    required this.createdAt,
  });
}
