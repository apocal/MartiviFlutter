import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:martivi/Constants/Constants.dart';
import 'package:martivi/Localizations/app_localizations.dart';
import 'package:martivi/ViewModels/MainViewModel.dart';
import 'package:martivi/Views/CategoryPage.dart';
import 'package:martivi/Widgets/Widgets.dart';
import 'package:provider/provider.dart';

class Login extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<MainViewModel>(
      builder: (_, viewmodel, child) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              AppLocalizations.of(context).translate('Welcome to'),
              style: TextStyle(
                fontSize: 16,
                color: kIcons,
                height: 2,
              ),
            ),
            Text(
              AppLocalizations.of(context).translate('App Name'),
              style: TextStyle(
                fontSize: 36,
                fontWeight: FontWeight.bold,
                color: kIcons,
                letterSpacing: 2,
                height: 1,
              ),
            ),
            Text(
              AppLocalizations.of(context)
                  .translate('Please login to continue'),
              style: TextStyle(
                fontSize: 16,
                color: kIcons,
                height: 1,
              ),
            ),
            SizedBox(
              height: 16,
            ),
            TextField(
              controller: viewmodel.emailController,
              keyboardType: TextInputType.emailAddress,
              style: TextStyle(color: kIcons),
              decoration: InputDecoration(
                hintText:
                    AppLocalizations.of(context).translate('Email / Username'),
                hintStyle: TextStyle(
                  fontSize: 16,
                  color: kIcons.withOpacity(.7),
                  fontWeight: FontWeight.bold,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25),
                  borderSide: BorderSide(
                    width: 0,
                    style: BorderStyle.none,
                  ),
                ),
                filled: true,
                fillColor: kPrimary_dark,
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 16, vertical: 0),
              ),
            ),
            SizedBox(
              height: 16,
            ),
            TextField(
              controller: viewmodel.passwordController,
              obscureText: true,
              style: TextStyle(color: kIcons),
              decoration: InputDecoration(
                hintText: AppLocalizations.of(context).translate('Password'),
                hintStyle: TextStyle(
                  fontSize: 16,
                  color: kIcons.withOpacity(.7),
                  fontWeight: FontWeight.bold,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25),
                  borderSide: BorderSide(
                    width: 0,
                    style: BorderStyle.none,
                  ),
                ),
                filled: true,
                fillColor: kPrimary_dark,
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 16, vertical: 0),
              ),
            ),
            SizedBox(
              height: 24,
            ),
            Container(
              height: 40,
              decoration: BoxDecoration(
                color: kIcons,
                borderRadius: BorderRadius.all(
                  Radius.circular(25),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Color(0xFF1C1C1C).withOpacity(0.2),
                    spreadRadius: 3,
                    blurRadius: 4,
                    offset: Offset(0, 3),
                  ),
                ],
              ),
              child: FlatButton(
                onPressed: () async {
                  try {
                    var res = await viewmodel.signInWithEmailAndPassword();

                    if (!res) {
                      showDialog(
                          context: context,
                          builder: (context) {
                            return OkDialog(
                                title: AppLocalizations.of(context)
                                    .translate('Error'),
                                content: AppLocalizations.of(context)
                                    .translate('Sign in failed'));
                          });
                    } else {
                      Navigator.of(context).pushNamed(CategoryPage.id);
                    }
                  } on PlatformException catch (pe) {
                    showDialog(
                        context: context,
                        builder: (context) {
                          return OkDialog(
                              title: AppLocalizations.of(context)
                                  .translate('Error'),
                              content: pe.message);
                        });
                  } catch (e) {
                    showDialog(
                        context: context,
                        builder: (context) {
                          return OkDialog(
                            title:
                                AppLocalizations.of(context).translate('Error'),
                            content:
                                '${AppLocalizations.of(context).translate('Sign in failed')}: ${AppLocalizations.of(context).translate('Unknown error')}',
                          );
                        });
                  } finally {
                    viewmodel.isSigningSignUping.value = false;
                  }
                },
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25)),
                child: Center(
                  child: Text(
                    AppLocalizations.of(context).translate('LOGIN'),
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: kPrimary,
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(
              height: 16,
            ),
            Text(
              AppLocalizations.of(context).translate('FORGOT PASSWORD?'),
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: kIcons,
                height: 1,
              ),
            ),
          ],
        );
      },
    );
  }
}
