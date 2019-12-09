import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:flutter/cupertino.dart';
import 'package:piggy_flutter/blocs/transaction/transaction.dart';
import 'package:piggy_flutter/blocs/transaction_detail/bloc.dart';
import 'package:piggy_flutter/repositories/account_repository.dart';
import './bloc.dart';

class AccountBloc extends Bloc<AccountEvent, AccountState> {
  final AccountRepository accountRepository;

  final TransactionBloc transactionsBloc;
  StreamSubscription transactionBlocSubscription;

  final TransactionDetailBloc transactionDetailBloc;
  StreamSubscription transactionDetailBlocSubscription;

  AccountBloc(
      {@required this.accountRepository,
      @required this.transactionsBloc,
      @required this.transactionDetailBloc})
      : assert(accountRepository != null),
        assert(transactionsBloc != null),
        assert(transactionDetailBloc != null) {
    transactionBlocSubscription = transactionsBloc.listen((state) {
      if (state is TransactionSaved) {
        add(RefreshAccount());
      }
    });

    transactionDetailBlocSubscription = transactionDetailBloc.listen((state) {
      if (state is TransactionDeleted) {
        add(RefreshAccount());
      }
    });
  }

  @override
  AccountState get initialState => AccountEmpty(null);

  @override
  Stream<AccountState> mapEventToState(
    AccountEvent event,
  ) async* {
    if (event is FetchAccount) {
      yield AccountLoading(event.accountId);

      try {
        var account =
            await accountRepository.getAccountDetails(event.accountId);

        yield AccountLoaded(account: account);
      } catch (e) {
        yield AccountFetchError(event.accountId);
      }
    }

    if (event is RefreshAccount) {
      add(FetchAccount(accountId: this.state.accountId));
    }
  }

  @override
  Future<void> close() {
    transactionDetailBlocSubscription.cancel();
    transactionBlocSubscription.cancel();
    return super.close();
  }
}
