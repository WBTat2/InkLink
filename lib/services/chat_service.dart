import 'package:cloud_firestore/cloud_firestore.dart';

class ChatService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<String> createChatForRequest({
    required String requestId,
    required String artistId,
    required String clientId,
  }) async {
    final chatRef = _db.collection('chats').doc();

    await chatRef.set({
      'id': chatRef.id,
      'requestId': requestId,
      'artistId': artistId,
      'clientId': clientId,
      'createdAt': FieldValue.serverTimestamp(),
      'lastMessage': '',
      'lastMessageAt': null,
      'lastSenderId': null,
      'isOpen': true,
    });

    return chatRef.id;
  }

  Future<void> sendMessage({
    required String chatId,
    required String senderId,
    required String text,
  }) async {
    final msgRef = _db
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .doc();

    await msgRef.set({
      'id': msgRef.id,
      'senderId': senderId,
      'text': text,
      'createdAt': FieldValue.serverTimestamp(),
      'messageType': 'text',
      'readBy': [senderId],
    });

    await _db.collection('chats').doc(chatId).update({
      'lastMessage': text,
      'lastMessageAt': FieldValue.serverTimestamp(),
      'lastSenderId': senderId,
    });
  }
}