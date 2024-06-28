import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:laundry_mgmt_system/Models/message.dart';
import 'package:laundry_mgmt_system/Models/scoped_model.dart';
import 'package:laundry_mgmt_system/Models/user_order.dart';
import 'package:scoped_model/scoped_model.dart';

class ChatPage extends StatefulWidget {
  final UserOrder userOrder;

  const ChatPage({super.key, required this.userOrder});

  @override
  // ignore: library_private_types_in_public_api
  _ChatPageState createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final TextEditingController _messageController = TextEditingController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final ScrollController _scrollController = ScrollController();
  List<Message> messages = [];
  //DateTime? lastTimestamp;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
            title: Text(
                ScopedModel.of<MyScopedModel>(context).authenticatedUser!.id ==
                        widget.userOrder.receiverId
                    ? widget.userOrder.senderName
                    : widget.userOrder.laundryName)),
        body:  ScopedModelDescendant<MyScopedModel>(
                builder: (context, child, model) => SafeArea(
                      child: Column(
                        children: <Widget>[
                          Expanded(
                            child: StreamBuilder<DocumentSnapshot>(
                              stream: _firestore
                                  .collection('userData')
                                  .doc(model.authenticatedUser!.id)
                                  .collection("orders")
                                  .doc(widget.userOrder.id)
                                  .snapshots(),
                              builder: (context, snapshot) {
                                if (snapshot.connectionState ==
                                    ConnectionState.waiting) {
                                  return const  Center(
                                      child: SizedBox(
                                    height: 70,
                                    width: 70,
                                  )); // Or any loading indicator
                                }

                                if (!snapshot.hasData ||
                                    !snapshot.data!.exists) {
                                  return const Text('No data available');
                                }

                                final messagesJson =
                                    snapshot.data!.get("messages");
                                messages = Message.fromJsonList(messagesJson);
                                // Sort the messages by timestamp
                                messages.sort((a, b) =>
                                    a.timestamp.compareTo(b.timestamp));

                                // Scroll to the end of the list
                                WidgetsBinding.instance
                                    .addPostFrameCallback((_) {
                                  _scrollController.animateTo(
                                    _scrollController.position.maxScrollExtent,
                                    duration: const Duration(milliseconds: 300),
                                    curve: Curves.easeOut,
                                  );
                                });

                                return ListView.builder(
                                  controller: _scrollController,
                                  itemCount: messages.length,
                                  shrinkWrap: true,
                                  itemBuilder: ((context, index) =>
                                      MessageWidget(message: messages[index])),
                                );
                              },
                            ),
                          ),
                          Padding(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 5, horizontal: 15),
                              child: Container(
                                padding: const EdgeInsets.all(3),
                                color: Colors.white,
                                child: Row(
                                  children: <Widget>[
                                    Expanded(
                                      child: TextField(
                                        controller: _messageController,
                                        decoration: const InputDecoration(
                                          hintText: 'Type your message...',
                                        ),
                                      ),
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.send),
                                      onPressed: () async {
                                        String msg = _messageController.text;
                                        _messageController.clear();
                                        var userOrder = UserOrder(
                                            id: widget.userOrder.id,
                                            senderId: widget.userOrder.senderId,
                                            receiverId:
                                                widget.userOrder.receiverId,
                                            senderName:
                                                widget.userOrder.senderName,
                                            laundryName:
                                                widget.userOrder.laundryName,
                                            items: List.from(
                                                widget.userOrder.items),
                                            status: widget.userOrder.status,
                                            requestReadyMethod: widget
                                                .userOrder.requestReadyMethod,
                                            requestCompletedMethod: widget
                                                .userOrder
                                                .requestCompletedMethod,
                                            orderPlacementTime: widget
                                                .userOrder.orderPlacementTime,
                                                orderAddress: widget.userOrder.orderAddress,
                                            messages: messages);
                                        userOrder.messages.add(Message(
                                            text: msg,
                                            timestamp: DateTime.now(),
                                            status: MessageStatus.sent,
                                            senderId:
                                                model.authenticatedUser!.id,
                                            receiverId: model.authenticatedUser!
                                                        .id ==
                                                    widget.userOrder.receiverId
                                                ? widget.userOrder.receiverId
                                                : widget.userOrder.senderId));
                                        ScopedModel.of<MyScopedModel>(context)
                                            .addUserOrder(userOrder, false);
                                      },
                                    ),
                                  ],
                                ),
                              )),
                        ],
                      ),
                    )));
  }
}

class MessageWidget extends StatelessWidget {
  final Message message;
  // ignore: prefer_const_constructors_in_immutables
  MessageWidget({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: message.senderId ==
              ScopedModel.of<MyScopedModel>(context).authenticatedUser!.id
          ? Alignment.centerRight
          : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
        decoration: BoxDecoration(
          color: message.senderId ==
                  ScopedModel.of<MyScopedModel>(context).authenticatedUser!.id
              ? Colors.blue
              : Colors.grey[300],
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16.0),
            topRight: const Radius.circular(16.0),
            bottomLeft: message.senderId ==
                    ScopedModel.of<MyScopedModel>(context).authenticatedUser!.id
                ? const Radius.circular(16.0)
                : Radius.zero,
            bottomRight: message.senderId ==
                    ScopedModel.of<MyScopedModel>(context).authenticatedUser!.id
                ? Radius.zero
                : const Radius.circular(16.0),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Text(
            message.text,
            style: TextStyle(
              color: message.senderId ==
                      ScopedModel.of<MyScopedModel>(context)
                          .authenticatedUser!
                          .id
                  ? Colors.white
                  : Colors.black,
              fontSize: 16.0,
            ),
          ),
        ),
      ),
    );
  }
}
