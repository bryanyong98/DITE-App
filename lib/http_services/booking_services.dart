import 'dart:convert';
import 'package:heard/api/booking_request.dart';
import 'package:heard/api/transaction.dart';
import 'package:heard/api/transaction_history.dart';
import 'package:http/http.dart' as http;
import 'package:heard/api/user.dart';

class BookingServices {
  Future<List<BookingRequest>> getAllCurrentRequests(
      {String headerToken}) async {
    var response = await http.get(
        'https://heard-project.herokuapp.com/booking/all_request',
        headers: {
          'Authorization': headerToken,
        });

    print(
        'Get all user booking request: ${response.statusCode}, body: ${response.body}');

    List<BookingRequest> bookingRequests = [];
    if (response.statusCode == 200) {
      List<dynamic> requestsBody = jsonDecode(response.body);
      for (int i = 0; i < requestsBody.length; i++) {
        BookingRequest request = BookingRequest.fromJson(requestsBody[i]);
        bookingRequests.add(request);
      }
    }

    return bookingRequests;
  }

  Future<bool> postSLIResponse(
      {String headerToken, String bookingID, bool isAcceptBooking}) async {
    var response = await http.post(
        'https://heard-project.herokuapp.com/booking/SLI_response',
        headers: {
          'Authorization': headerToken,
        },
        body: {
          'booking_id': bookingID,
          'response': isAcceptBooking ? 'accept' : 'decline'
        });

    print(
        'Posted SLI Response: ${response.statusCode}, body: ${response.body}');

    if (response.statusCode == 200) {
      return true;
    } else {
      return false;
    }
  }

  Future<List<Transaction>> getAllTransactions(
      {String headerToken, bool isSLI}) async {
    var response = await http.get(
        'https://heard-project.herokuapp.com/booking/get_bookings?type=${isSLI ? 'sli' : 'user'}',
        headers: {
          'Authorization': headerToken,
        });

    print(
        'Get all transactions: ${response.statusCode}, body: ${response.body}');

    List<Transaction> allTransactions = [];
    if (response.statusCode == 200) {
      List<dynamic> requestsBody = jsonDecode(response.body);
      for (int i = 0; i < requestsBody.length; i++) {
        Transaction request = Transaction.fromJson(requestsBody[i]);
        allTransactions.add(request);
      }
    }

    return allTransactions;
  }

  Future<List<TransactionHistory>> getTransactionHistory({String headerToken, bool isSLI}) async {
    var response = await http.get(
        'https://heard-project.herokuapp.com/booking/history?type=${isSLI ? 'sli' : 'user'}',
        headers: {
          'Authorization': headerToken,
        });

    print('Get all transaction history: ${response.statusCode}, body: ${response.body}');

    List<TransactionHistory> transactionHistory = [];
    if (response.statusCode == 200) {
      List<dynamic> requestsBody = jsonDecode(response.body);
      for (int i = 0; i < requestsBody.length; i++) {
        TransactionHistory request = TransactionHistory.fromJson(requestsBody[i]);
        transactionHistory.add(request);
      }
    }

    return transactionHistory;
  }

  Future<bool> cancelBooking({String headerToken, String bookingID}) async {
    var response = await http
        .post('https://heard-project.herokuapp.com/booking/cancel', headers: {
      'Authorization': headerToken,
    }, body: {
      'booking_id': bookingID,
    });

    print(
        'Cancel Booking Response: ${response.statusCode}, body: ${response.body}');

    if (response.statusCode == 200) {
      return true;
    } else {
      return false;
    }
  }

  Future<bool> finishBooking({String headerToken, String bookingID}) async {
    var response = await http
        .post('https://heard-project.herokuapp.com/booking/end', headers: {
      'Authorization': headerToken,
    }, body: {
      'booking_id': bookingID,
    });

    print(
        'End/Finish Booking Response: ${response.statusCode}, body: ${response.body}');

    if (response.statusCode == 200) {
      return true;
    } else {
      return false;
    }
  }

  Future<List<User>> getAllSLI({String headerToken}) async {
    var response = await http
        .get('https://heard-project.herokuapp.com/booking/all_sli', headers: {
      'Authorization': headerToken,
    });

    List<User> allSli = [];
    if (response.statusCode == 200) {
      List<dynamic> requestsBody = jsonDecode(response.body);
      for (int i = 0; i < requestsBody.length; i++) {
        User user = User.fromJson(requestsBody[i]);
        allSli.add(user);
      }
    }
    return allSli;
  }

  Future<int> requestBooking(
      {String headerToken,
      String sliId,
      String date,
      String time,
      String hospitalName,
      String notes}) async {
    var response = await http
        .post('https://heard-project.herokuapp.com/booking/request', headers: {
      'Authorization': headerToken,
    }, body: {
      'sli_id': sliId,
      'date': date,
      'time': time,
      'hospital_name': hospitalName,
      'notes': notes,
    });

    return response.statusCode;
  }
}
