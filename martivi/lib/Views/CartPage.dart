import 'package:flutter/cupertino.dart';
import 'package:martivi/Models/CartItem.dart';
import 'package:martivi/ViewModels/MainViewModel.dart';
import 'package:martivi/Views/ProductPage.dart';
import 'package:provider/provider.dart';

class CartPage extends StatefulWidget {
  @override
  _CartPageState createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  @override
  Widget build(BuildContext context) {
    return Consumer<MainViewModel>(
      builder: (context, viewModel, child) {
        return ValueListenableBuilder<List<CartItem>>(
          valueListenable: viewModel.cart,
          builder: (context, value, child) {
            return Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    itemCount: viewModel.cart.value.length,
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: EdgeInsets.all(8),
                        child: ProductItem(
                          p: viewModel.cart.value[index].product,
                        ),
                      );
                    },
                  ),
                )
              ],
            );
          },
        );
      },
    );
  }
}
