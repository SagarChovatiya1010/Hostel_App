import 'package:flutter/material.dart';

class HorizontalList extends StatelessWidget {
  String image_location;
  String image_caption;
  String image_vicinity;
  String rating;

  HorizontalList(
      {this.image_location,
      this.image_caption,
      this.image_vicinity,
      this.rating});
  @override
  Widget build(BuildContext context) {
    print("aama ghusne bhai");
    print(image_location);
    print(image_caption);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 2),
      child: Card(
        child: InkWell(
          onTap: () {},
          child: Padding(
            padding: const EdgeInsets.all(2.0),
            child: Container(
              width: 360,
              height: 270.0,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: EdgeInsets.only(left: 10, right: 10, top: 8),
                        width: 100,
                        height: 100,
                        child: Image.network(
                          image_location,
                          fit: BoxFit.cover,
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.only(bottom: 8),
                        child: Text("Rating: $rating"),
                      )
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      FittedBox(
                        child: Container(
                          //width: 260,
                          padding: EdgeInsets.only(top: 5),
                          alignment: Alignment.topCenter,
                          child: Text(
                            image_caption,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 16.0,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                      ),
                      FittedBox(
                        child: Container(
                          width: 260,
                          alignment: Alignment.topCenter,
                          child: Text(
                            image_vicinity,
                            style: TextStyle(fontSize: 16.0),
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                      Container(
                        // margin: EdgeInsets.all(20),
                        padding: EdgeInsets.only(left:60),
                        child: FlatButton(
                          child: Text('Direction'),
                          color: Colors.blueAccent,
                          textColor: Colors.white,
                          onPressed: () {},
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              // ListTile(
              //   title: Image.asset(
              //     image_location,
              //     fit: BoxFit.cover,
              //   ),
              //   subtitle: Container(
              //     alignment: Alignment.topCenter,
              //     child: Text(image_caption, style:TextStyle(fontSize: 16.0),),
              //   )
              // ),
            ),
          ),
        ),
      ),
    );
  }
}
