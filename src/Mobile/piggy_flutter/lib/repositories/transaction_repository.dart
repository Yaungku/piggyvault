import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:intl/intl.dart';
import 'package:piggy_flutter/models/api_response.dart';
import 'package:piggy_flutter/models/models.dart';
import 'package:piggy_flutter/repositories/piggy_api_client.dart';

class TransactionRepository {
  final PiggyApiClient piggyApiClient;

  TransactionRepository({@required this.piggyApiClient})
      : assert(piggyApiClient != null);

  Future<TransactionSummary> getTransactionSummary(String duration) async {
    return await piggyApiClient.getTransactionSummary(duration);
  }

  Future<ApiResponse<dynamic>> createOrUpdateTransaction(
      TransactionEditDto input) async {
    return await piggyApiClient.createOrUpdateTransaction(input);
  }

  Future<ApiResponse<dynamic>> transfer(TransferInput input) async {
    return await piggyApiClient.transfer(input);
  }

  Future<TransactionsResult> getTransactions(GetTransactionsInput input) async {
    var transactions = await piggyApiClient.getTransactions(input);

    return TransactionsResult(
        sections: groupTransactions(
            transactions: transactions, groupBy: input.groupBy),
        transactions: transactions);
  }

  Future<void> deleteTransaction(String id) async {
    await piggyApiClient.deleteTransaction(id);
  }

  Future<void> createOrUpdateTransactionComment(
      String transactionId, String content) async {
    await piggyApiClient.createOrUpdateTransactionComment(
        transactionId, content);
  }

  Future<List<TransactionComment>> getTransactionComments(String id) async {
    return await piggyApiClient.getTransactionComments(id);
  }

  // Utils

  List<TransactionGroupItem> groupTransactions(
      {List<Transaction> transactions,
      TransactionsGroupBy groupBy = TransactionsGroupBy.Date}) {
    List<TransactionGroupItem> sections = [];
    var formatter = DateFormat("EEE, MMM d, ''yy");
    String key;

    transactions.forEach((transaction) {
      if (groupBy == TransactionsGroupBy.Date) {
        key = formatter.format(DateTime.parse(transaction.transactionTime));
      } else if (groupBy == TransactionsGroupBy.Category) {
        key = transaction.categoryName;
      }

      var section =
          sections.firstWhere((o) => o.title == key, orElse: () => null);

      if (section == null) {
        section = TransactionGroupItem(title: key, groupby: groupBy);
        sections.add(section);
      }

      if (transaction.amountInDefaultCurrency > 0) {
        section.totalInflow += transaction.amountInDefaultCurrency;
      } else {
        section.totalOutflow += transaction.amountInDefaultCurrency;
      }

      section.transactions.add(transaction);
    });

    return sections;
  }
}
