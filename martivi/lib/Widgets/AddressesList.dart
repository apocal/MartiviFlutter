import 'package:flutter/material.dart';
import 'package:martivi/Constants/Constants.dart';
import 'package:martivi/Localizations/app_localizations.dart';
import 'package:martivi/Models/Address.dart';

class AddressesList extends StatefulWidget {
  final Function(UserAddress) addressSelected;
  final List<UserAddress> userAddresses;
  AddressesList({this.userAddresses, this.addressSelected});
  @override
  _AddressesListState createState() => _AddressesListState();
}

class _AddressesListState extends State<AddressesList> {
  int selectedValue = -1;
  @override
  Widget build(BuildContext context) {
    selectedValue = -1;
    if ((widget.userAddresses?.length ?? 0) > 0) {
      for (int i = 0; i < widget.userAddresses.length; i++) {
        if (widget.userAddresses[i].isPrimary ?? false) {
          selectedValue = i;
          widget.addressSelected?.call(widget.userAddresses[i]);
          break;
        }
      }
    }
    return Column(
        children: widget.userAddresses.map((e) {
      return RadioListTile(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(e.name),
            SizedBox(
              width: 4,
            ),
            Text(
              e.addressName,
              style: TextStyle(color: Colors.black54),
            )
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(e.address),
            Text(
                '${AppLocalizations.of(context).translate('Phone')} ${e.mobileNumber}')
          ],
        ),
        secondary: FlatButton(
          splashColor: kPrimary.withOpacity(0.2),
          highlightColor: kPrimary.withOpacity(.2),
          child: Text(
            AppLocalizations.of(context).translate('Delete'),
            style: TextStyle(color: kPrimary),
          ),
          onPressed: () {
            e.referance.delete();
          },
        ),
        activeColor: kPrimary,
        value: selectedValue,
        groupValue: widget.userAddresses.indexOf(e),
        onChanged: (val) {
          try {
            widget.userAddresses[val].referance
                .updateData({'isPrimary': false});
          } catch (e) {}

          e.referance.updateData({'isPrimary': true});
          widget.addressSelected?.call(e);
          setState(() {
            selectedValue = widget.userAddresses.indexOf(e);
          });
        },
      );
    }).toList());
  }
}
