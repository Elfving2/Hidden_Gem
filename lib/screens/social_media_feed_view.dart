import 'package:flutter/material.dart';

class SocialMediaFeed extends StatefulWidget {
  const SocialMediaFeed({super.key});

  @override
  State<SocialMediaFeed> createState() => _SocialMediaFeedState();
}

class _SocialMediaFeedState extends State<SocialMediaFeed> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Center(child: Text("Feed")),
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            PostWidget(
              heading: "Cool camera",
              pictureLink:
                  "https://www.bigfootdigital.co.uk/wp-content/uploads/2020/07/image-optimisation-scaled.jpg",
              author: "Nellie Elfving",
            ),
            PostWidget(
              heading: "Sun",
              pictureLink:
                  "https://cdn.pixabay.com/photo/2018/08/04/11/30/draw-3583548_1280.png",
              author: "Sebastian Elfving",
            ),
            PostWidget(
              heading: "WOOOW LOOK",
              pictureLink:
                  "https://img-cdn.pixlr.com/image-generator/demo/pixlr-image-generator-example-2.webp",
              author: "Robert Jones",
            ),
            PostWidget(
              heading: "Tower",
              pictureLink:
                  "https://img-cdn.pixlr.com/image-generator/demo/pixlr-image-generator-example-6.webp",
              author: "Matilda Elfving",
            ),
          ],
        ),
      ),
    );
  }
}

class PostWidget extends StatefulWidget {
  final String heading;
  final String pictureLink;
  final String author;

  const PostWidget({
    required this.heading,
    required this.pictureLink,
    required this.author,
    super.key,
  });

  @override
  State<PostWidget> createState() => _PostWidgetState();
}

class _PostWidgetState extends State<PostWidget> {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      child: Column(
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 15,
                backgroundImage: NetworkImage(
                  "https://images.pexels.com/photos/33875524/pexels-photo-33875524.jpeg",
                ),
              ),
              SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.author,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  Text(
                    widget.heading,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
            ],
          ),
          SizedBox(height: 10),
          Container(
            height: 300,
            decoration: BoxDecoration(
              image: DecorationImage(
                image: NetworkImage(widget.pictureLink),
                fit: BoxFit.cover,
              ),
            ),
          ),
          SizedBox(height: 10),
          Row(
            children: [
              IconButton(
                icon: Icon(Icons.favorite, color: Colors.red),
                onPressed: () {},
              ),
              SizedBox(width: 10),
              IconButton(
                icon: Icon(Icons.comment, color: Colors.blue),
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return commentSection();
                    },
                  );
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}

Widget commentSection() {
  return Align(
    alignment: Alignment.bottomCenter,
    child: Container(
      height: 550,
      decoration: BoxDecoration(
        color: Colors.grey,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(16),
            child: Text(
              "Comments",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ),
          // Divider (optional)
          Divider(height: 1, color: Colors.black26),

          // Scrollable list of comments
          Expanded(
            child: ListView.separated(
              padding: EdgeInsets.all(12),
              itemCount: 15,
              separatorBuilder: (context, index) => SizedBox(height: 15),
              itemBuilder: (context, index) => comment("Sebastian Elfving"),
            ),
          ),
          commentButton(),
        ],
      ),
    ),
  );
}

Widget comment(String author) {
  return Row(
    children: [
      CircleAvatar(
        radius: 15,
        backgroundImage: NetworkImage(
          "https://images.pexels.com/photos/33875524/pexels-photo-33875524.jpeg",
        ),
      ),
      SizedBox(width: 10),
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            author,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          Text("This is a comment"),
        ],
      ),
    ],
  );
}

Widget commentButton() {
  return Material(
    //color: Colors.red,
    child: Container(
      color: Colors.grey,
      height: 100,
      padding: EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              decoration: InputDecoration(
                hintText: "Write a comment...",
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide.none,
                ),
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
              ),
            ),
          ),
          SizedBox(width: 8),
          IconButton(
            icon: Icon(Icons.send, color: Colors.white),
            onPressed: () {
              // send comment logic
            },
          ),
        ],
      ),
    ),
  );
}
