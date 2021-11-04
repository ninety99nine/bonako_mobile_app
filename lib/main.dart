import './screens/dashboard/stores/list/stores_screen.dart';
import 'package:intro_slider/slide_object.dart';
import 'package:intro_slider/intro_slider.dart';
import 'package:flutter_svg/flutter_svg.dart';
import './screens/auth/forgot_password.dart';
import './screens/auth/reset_password.dart';
import './screens/auth/one_time_pin.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import './screens/auth/welcome.dart';
import './screens/auth/signup.dart';
import './providers/locations.dart';
import './screens/auth/login.dart';
import './providers/products.dart';
import './providers/stores.dart';
import './providers/orders.dart';
import './providers/auth.dart';
import './providers/api.dart';
import 'package:get/get.dart';
import 'dart:convert';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {

    print('Building MyApp');

    return MultiProvider(
      providers: [
        ChangeNotifierProvider<ApiProvider>(
          create: (_) => ApiProvider()
        ),
        /**
         *  Note: We have to use the ChangeNotifierProxyProvider instead of 
         *  ChangeNotifierProvider because the AuthProvider requires the
         *  ApiProvider as a dependency. When the ApiProvider changes,
         *  then the AuthProvider will also rebuild.
         */
        ChangeNotifierProxyProvider<ApiProvider, AuthProvider>(
          create: (_) => AuthProvider(apiProvider: ApiProvider()),
          update: (ctx, apiProvider, previousAuthProvider) => AuthProvider(apiProvider: apiProvider)
        ),
        /**
         *  Note: We have to use the ChangeNotifierProxyProvider instead of 
         *  ChangeNotifierProvider because the StoresProvider requires the
         *  AuthProvider as a dependency. When the AuthProvider changes,
         *  then the StoresProvider will also rebuild.
         */
        ChangeNotifierProxyProvider<AuthProvider, StoresProvider>(
          create: (_) => StoresProvider(authProvider: AuthProvider(apiProvider: ApiProvider())),
          update: (ctx, authProvider, previousStoresProvider) => StoresProvider(authProvider: authProvider)
        ),
        /**
         *  Note: We have to use the ChangeNotifierProxyProvider instead of 
         *  ChangeNotifierProvider because the LocationsProvider requires the
         *  StoresProvider as a dependency. When the StoresProvider changes,
         *  then the LocationsProvider will also rebuild.
         */
        ChangeNotifierProxyProvider<StoresProvider, LocationsProvider>(
          create: (_) => LocationsProvider(storesProvider: StoresProvider(authProvider: AuthProvider(apiProvider: ApiProvider()))),
          update: (ctx, storesProvider, previousLocationsProvider) => LocationsProvider(storesProvider: storesProvider)
        ),
        /**
         *  Note: We have to use the ChangeNotifierProxyProvider instead of 
         *  ChangeNotifierProvider because the OrdersProvider requires the
         *  LocationsProvider as a dependency. When the LocationsProvider changes,
         *  then the OrdersProvider will also rebuild.
         */
        ChangeNotifierProxyProvider<LocationsProvider, OrdersProvider>(
          create: (_) => OrdersProvider(locationsProvider: LocationsProvider(storesProvider: StoresProvider(authProvider: AuthProvider(apiProvider: ApiProvider())))),
          update: (ctx, locationsProvider, previousOrdersProvider) => OrdersProvider(locationsProvider: locationsProvider)
        ),
        /**
         *  Note: We have to use the ChangeNotifierProxyProvider instead of 
         *  ChangeNotifierProvider because the OrdersProvider requires the
         *  LocationsProvider as a dependency. When the LocationsProvider changes,
         *  then the OrdersProvider will also rebuild.
         */
        ChangeNotifierProxyProvider<LocationsProvider, ProductsProvider>(
          create: (_) => ProductsProvider(locationsProvider: LocationsProvider(storesProvider: StoresProvider(authProvider: AuthProvider(apiProvider: ApiProvider())))),
          update: (ctx, locationsProvider, previousProductsProvider) => ProductsProvider(locationsProvider: locationsProvider)
        ),
      ],
      child: GetMaterialApp(
        title: 'Bonako',
        theme: ThemeData(
          //  primarySwatch: kPrimaryColor,
          accentColor: Colors.blue,
          splashColor: Colors.white.withOpacity(0.3),
          highlightColor: Colors.white.withOpacity(0.2),
        ),
        
        home: AppScreen(),
    
        //  initialRoute: '/',
        routes: {
          LoginPage.routeName: (ctx) => LoginPage(),
          WelcomePage.routeName: (ctx) => WelcomePage(),
          SignUpPage.routeName: (ctx) => SignUpPage(),
          ForgotPasswordPage.routeName: (ctx) => ForgotPasswordPage(),
          OneTimePinPage.routeName: (ctx) => OneTimePinPage(),
          ResetPasswordPage.routeName: (ctx) => ResetPasswordPage(),
          StoresScreen.routeName: (ctx) => StoresScreen(),
        }
      ),
    );
  }
}

class AppScreen extends StatefulWidget {

  @override
  _AppScreenState createState() => _AppScreenState();
  
}

class _AppScreenState extends State<AppScreen> {

  var isLoading = false;

  void startLoader(){
    setState(() {
      isLoading = true;
    });
  }

  void stopLoader(){
    setState(() {
      isLoading = false;
    });
  }

  @override
  void initState() {

    print('initState: AppScreen');

    setApiEndpoints();

    super.initState();

  }

  @override
  void didUpdateWidget(covariant AppScreen oldWidget) {

    print('didUpdateWidget: AppScreen');

    setApiEndpoints();
    
    super.didUpdateWidget(oldWidget);

  }

  void setApiEndpoints(){

    print('start setApiEndpoints()');

    startLoader();
    
    //  Set the API endpoints
    Provider.of<ApiProvider>(context, listen: false).setApiEndpoints(context: context)
      .then((http.Response response) async {

        print('finish setApiEndpoints()');

        //  If this is a successful request
        if( response.statusCode == 200 ){

          final responseBody = jsonDecode(response.body);
        
          final authenticationStatus = responseBody['_embedded']['authenticated'];

          final authProvider = Provider.of<AuthProvider>(context, listen: false);
          
          authProvider.setAuthenticatedStatus(authenticationStatus);

          if( authProvider.isAuthenticated ){
            
            /**
             * Lets first set the authenticated user stored on the device as the currently
             * authenticated user on the AuthProvider._user property. This will allow us
             * to have access to this authenticated user's information. We use the async
             * and await here so that we can keep isLoading = true until this completes.
             */
            await authProvider.setUserFromDevice();

          }

          /**
           * Set if we have seen the intro screen before
           */
          await authProvider.setHasViewedIntroFromDevice();

        }

      }).whenComplete((){

        stopLoader();

      });
  }

  @override
  Widget build(BuildContext context) {

    print('Building Bonako App');

    final authProvider = Provider.of<AuthProvider>(context);

    //  Check for user authentication status
    final isAuthenticated = authProvider.isAuthenticated;

    //  Check for authenticated user
    final hasAuthUser = authProvider.hasAuthUser;

    //  Check for authenticated user
    final hasViewedIntro = authProvider.hasViewedIntro;

    print('isAuthenticated: '+isAuthenticated.toString());
    print('hasAuthUser: '+hasAuthUser.toString());

    return 
      isLoading
        ? LoadingScreen() : 
        //  If we have not seen the intro screen
          hasViewedIntro == false ? IntroScreen()
            //  If we are authenticated show the stores otherwise show the login page
            : ((isAuthenticated && hasAuthUser) ? StoresScreen() : WelcomePage());
  }

}

class LoadingScreen extends StatelessWidget {

  Widget _backgroundImage(context) {
    return Container(
      height: MediaQuery.of(context).size.height,
      decoration: BoxDecoration(
        image: DecorationImage(
          fit: BoxFit.cover,
          image: AssetImage('assets/images/street-vendors.jpeg')
        )
      ),
    );
  }

  Widget _backgroundGradient(context) {
    return Container(
      height: MediaQuery.of(context).size.height,
      decoration: BoxDecoration(
        gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Colors.blue.shade500.withOpacity(0.8), Colors.blue.shade900]
        )
      )
    );
  }

  Widget _content(context) {
    return Container(
      width: double.infinity,
      
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(color: Colors.white,),
          SizedBox(height: 20),
          Text('Loading', style: TextStyle(
            fontWeight: FontWeight.bold, 
            color: Colors.white
          ))
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    //  Show the circular progress bar
    return Scaffold(
      body: Stack(
        children: [

          _backgroundImage(context),

          _backgroundGradient(context),

          _content(context),

        ],
      ),
    );
  }
}

class IntroScreen extends StatefulWidget{

  @override
  _IntroScreenState createState() => _IntroScreenState();
}

class _IntroScreenState extends State<IntroScreen> {
  
  List<Slide> slides = [];

  @override
  void initState() {

    super.initState();

    slides.add(

      //  Slide 1
      new Slide(

        colorBegin: Colors.blue,
        colorEnd: Colors.blue.shade900,
        
        centerWidget: Column(
          children: [
            Container(
              width: 100,
              height: 100,
              padding: EdgeInsets.all(30),
              decoration: BoxDecoration(
                color: Colors.blue.shade300,
                borderRadius: BorderRadius.circular(50),
                border: Border.all(color: Colors.white)
              ),
              child: SvgPicture.asset('assets/icons/ecommerce_pack_1/shop.svg', color: Colors.white),
            ),
            SizedBox(height: 50),
            Text('Welcome to Bonako', style: TextStyle(color: Colors.white, fontSize: 30.0, fontWeight: FontWeight.bold),),
            SizedBox(height: 25),
            Container(
              margin: EdgeInsets.symmetric(horizontal: 20),
              child: Text('Bonako is a platform that empowers merchants to sell their goods and services without the need of setting up a physical store', textAlign: TextAlign.center, style: TextStyle(color: Colors.white, fontStyle: FontStyle.italic))
            )
          ],
        ),
        
        onCenterItemPress: () {},
      ),
    );

    //  Slide 2
    slides.add(
      new Slide(

        colorBegin: Colors.blue,
        colorEnd: Colors.blue.shade900,
        
        centerWidget: Column(
          children: [
            Container(
              width: 100,
              height: 100,
              padding: EdgeInsets.all(30),
              decoration: BoxDecoration(
                color: Colors.blue.shade300,
                borderRadius: BorderRadius.circular(50),
                border: Border.all(color: Colors.white)
              ),
              child: SvgPicture.asset('assets/icons/ecommerce_pack_1/trolley.svg', color: Colors.white),
            ),
            SizedBox(height: 50),
            Text('How It Works', style: TextStyle(color: Colors.white, fontSize: 30.0, fontWeight: FontWeight.bold),),
            Divider(color: Colors.white, height: 30,),
            Container(
              margin: EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Step 1:', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                      SizedBox(width: 10),
                      Flexible(child: Text('First you need to create a store. Every store on Bonako gets a shortcode e.g *250*11#', style: TextStyle(color: Colors.white, fontStyle: FontStyle.italic))),
                    ],
                  ),
                  SizedBox(height: 10),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text('Step 2:', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                      SizedBox(width: 10),
                      Flexible(child: Text('Add products to your store', style: TextStyle(color: Colors.white, fontStyle: FontStyle.italic))),
                    ],
                  ),
                  SizedBox(height: 10),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Step 3:', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                      SizedBox(width: 10),
                      Flexible(child: Text('Share your shortcode e.g *250*11# with customers on Social Media or by printing on paper', style: TextStyle(color: Colors.white, fontStyle: FontStyle.italic))),
                    ],
                  ),
                  SizedBox(height: 10),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Step 4:', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                      SizedBox(width: 10),
                      Flexible(child: Text('Customers dial shortcode to select products to buy and place orders', style: TextStyle(color: Colors.white, fontStyle: FontStyle.italic))),
                    ],
                  ),
                  SizedBox(height: 10),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Step 5:', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                      SizedBox(width: 10),
                      Flexible(child: Text('Handle orders on the Bonako App and get paid by your customer on delivery', style: TextStyle(color: Colors.white, fontStyle: FontStyle.italic))),
                    ],
                  ),
                  Divider(color: Colors.white, height: 30,),

                  Text('It is possible to allow customers to pay directly using Orange Money instead of hard cash. Please visit the nearest Orange shop to learn more', textAlign: TextAlign.center, style: TextStyle(color: Colors.white, fontStyle: FontStyle.italic))
                ],
              )
            )
          ],
        ),
        
        onCenterItemPress: () {},
      ),
    );

    //  Slide 3
    slides.add(
      new Slide(

        colorBegin: Colors.blue,
        colorEnd: Colors.blue.shade900,
        
        centerWidget: Column(
          children: [
            Container(
              width: 100,
              height: 100,
              padding: EdgeInsets.all(30),
              decoration: BoxDecoration(
                color: Colors.blue.shade300,
                borderRadius: BorderRadius.circular(50),
                border: Border.all(color: Colors.white)
              ),
              child: SvgPicture.asset('assets/icons/ecommerce_pack_1/shopping-bag-2.svg', color: Colors.white),
            ),
            SizedBox(height: 50),
            Text('Selling made easy', style: TextStyle(color: Colors.white, fontSize: 30.0, fontWeight: FontWeight.bold),),
            SizedBox(height: 25),
            Container(
              margin: EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  Text('Bonako allows you to sell creatively without any limitations. You can sell almost anything on Bonako. Sell food, drinks, tools, equipment, tickets, beauty products, clothes and so much more', textAlign: TextAlign.center, style: TextStyle(color: Colors.white, fontStyle: FontStyle.italic)),

                  Divider(color: Colors.white, height: 30,),

                  Text('Visit our Facebook page *Bonako Dial2Buy* to learn more about selling different types of products', textAlign: TextAlign.center, style: TextStyle(color: Colors.white, fontStyle: FontStyle.italic)),
                ]
              )
            )
          ],
        ),
        onCenterItemPress: () {},
      ),
    );

    //  Slide 4
    slides.add(
      new Slide(

        colorBegin: Colors.blue,
        colorEnd: Colors.blue.shade900,
        
        centerWidget: Column(
          children: [
            Container(
              width: 100,
              height: 100,
              padding: EdgeInsets.all(30),
              decoration: BoxDecoration(
                color: Colors.blue.shade300,
                borderRadius: BorderRadius.circular(50),
                border: Border.all(color: Colors.white)
              ),
              child: SvgPicture.asset('assets/icons/ecommerce_pack_1/discount-coupon.svg', color: Colors.white),
            ),
            SizedBox(height: 50),
            Text('Discounts & Promotions', style: TextStyle(color: Colors.white, fontSize: 30.0, fontWeight: FontWeight.bold),),
            SizedBox(height: 25),
            Container(
              margin: EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  Text('Bonako helps to support your business by giving you the tools needed to give your customers special incentives. Using Bonako you can create coupons that allow your customers to claim special discounts based on different kinds of rules e.g:', textAlign: TextAlign.center, style: TextStyle(color: Colors.white, fontStyle: FontStyle.italic)),

                  Divider(color: Colors.white, height: 30,),

                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('#', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                      SizedBox(width: 10),
                      Flexible(child: Text('Discount only new customers', style: TextStyle(color: Colors.white, fontStyle: FontStyle.italic))),
                    ],
                  ),

                  SizedBox(height: 10),

                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('#', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                      SizedBox(width: 10),
                      Flexible(child: Text('Discount only return customers', style: TextStyle(color: Colors.white, fontStyle: FontStyle.italic))),
                    ],
                  ),

                  SizedBox(height: 10),
                  
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('#', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                      SizedBox(width: 10),
                      Flexible(child: Text('Discount only from this date to that date', style: TextStyle(color: Colors.white, fontStyle: FontStyle.italic))),
                    ],
                  ),

                  SizedBox(height: 10),
                  
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('#', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                      SizedBox(width: 10),
                      Flexible(child: Text('Discount only for the first X number of customers', style: TextStyle(color: Colors.white, fontStyle: FontStyle.italic))),
                    ],
                  ),

                  SizedBox(height: 10),
                  
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('#', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                      SizedBox(width: 10),
                      Flexible(child: Text('Discount only for customers spending more than X amount of money', style: TextStyle(color: Colors.white, fontStyle: FontStyle.italic))),
                    ],
                  ),

                  SizedBox(height: 10),
                  
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('... and it doesn\'t end here', style: TextStyle(color: Colors.white, fontSize: 18,))
                    ],
                  ),

                  Divider(color: Colors.white, height: 30,),

                  Text('Visit our Facebook page *Bonako Dial2Buy* to learn more about coupons and how they can be used to offer discounts & promotions', textAlign: TextAlign.center, style: TextStyle(color: Colors.white, fontStyle: FontStyle.italic)),
                ]
              )
            )
          ],
        ),
        onCenterItemPress: () {},
      ),
    );

    //  Slide 5
    slides.add(
      new Slide(

        colorBegin: Colors.blue,
        colorEnd: Colors.blue.shade900,
        
        centerWidget: Column(
          children: [
            Container(
              width: 100,
              height: 100,
              padding: EdgeInsets.all(30),
              decoration: BoxDecoration(
                color: Colors.blue.shade300,
                borderRadius: BorderRadius.circular(50),
                border: Border.all(color: Colors.white)
              ),
              child: SvgPicture.asset('assets/icons/ecommerce_pack_1/shopping-cart-10.svg', color: Colors.white),
            ),
            SizedBox(height: 50),
            Text('Instant Carts', style: TextStyle(color: Colors.white, fontSize: 30.0, fontWeight: FontWeight.bold),),
            SizedBox(height: 25),
            Container(
              margin: EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  Text('Normally a customer needs to dial a shortcode to visit your store, then select the products they want and quantities before they actually can checkout. This can be too slow for simple orders.', textAlign: TextAlign.center, style: TextStyle(color: Colors.white, fontStyle: FontStyle.italic)),

                  Divider(color: Colors.white, height: 30,),
                  
                  Text('Instant carts offer a faster way for customers to checkout and place orders by simply dialing a shortcode. This is how it works:', textAlign: TextAlign.center, style: TextStyle(color: Colors.white, fontStyle: FontStyle.italic)),

                  Divider(color: Colors.white, height: 30,),

                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Step 1', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                      SizedBox(width: 10),
                      Flexible(child: Text('Create an instant cart with specific products and their quantities', style: TextStyle(color: Colors.white, fontStyle: FontStyle.italic))),
                    ],
                  ),

                  SizedBox(height: 10),

                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Step 2', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                      SizedBox(width: 10),
                      Flexible(child: Text('Add special discounts if required e.g 10% discount for everything in the cart', style: TextStyle(color: Colors.white, fontStyle: FontStyle.italic))),
                    ],
                  ),

                  SizedBox(height: 10),

                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Step 3', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                      SizedBox(width: 10),
                      Flexible(child: Text('A shortcode linked to this instant cart will be generated e.g *250*12#', style: TextStyle(color: Colors.white, fontStyle: FontStyle.italic))),
                    ],
                  ),

                  SizedBox(height: 10),

                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Step 4', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                      SizedBox(width: 10),
                      Flexible(child: Text('Customer dials the shortcode and the products and discounts suggested will be added for checkout allowing the customer to checkout faster.', style: TextStyle(color: Colors.white, fontStyle: FontStyle.italic))),
                    ],
                  ),

                  Divider(color: Colors.white, height: 30,),

                  Text('Visit our Facebook page *Bonako Dial2Buy* to learn more about instant carts and how they can be used for faster checkouts', textAlign: TextAlign.center, style: TextStyle(color: Colors.white, fontStyle: FontStyle.italic)),
                ]
              )
            )
          ],
        ),
        onCenterItemPress: () {},
      ),
    );

  }

  void onDonePress() {
    Provider.of<AuthProvider>(context, listen: false).storeHasViewedIntroOnDevice();
  }

  Widget renderNextBtn() {
    return Icon(
      Icons.navigate_next,
      color: Colors.white,
      size: 35.0,
    );
  }

  Widget renderDoneBtn() {
    return Icon(
      Icons.done,
      color: Colors.white,
    );
  }

  Widget renderSkipBtn() {
    return Icon(
      Icons.skip_next,
      color: Colors.white,
    );
  }

  ButtonStyle myButtonStyle() {
    return ButtonStyle(
      shape: MaterialStateProperty.all<OutlinedBorder>(StadiumBorder()),
      backgroundColor: MaterialStateProperty.all<Color>(Color(0x33F3B4BA)),
      overlayColor: MaterialStateProperty.all<Color>(Color(0x33FFA8B0)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return new IntroSlider(
      
      // List slides
      slides: this.slides,

      // Skip button
      renderSkipBtn: this.renderSkipBtn(),
      skipButtonStyle: myButtonStyle(),

      // Next button
      renderNextBtn: this.renderNextBtn(),
      nextButtonStyle: myButtonStyle(),

      // Done button
      renderDoneBtn: this.renderDoneBtn(),
      onDonePress: this.onDonePress,
      doneButtonStyle: myButtonStyle(),

      // Dot indicator
      colorDot: Colors.white.withOpacity(0.2),
      colorActiveDot: Colors.white,
      sizeDot: 13.0,

      // Show or hide status bar
      hideStatusBar: true,
      backgroundColorAllSlides: Colors.grey,

      // Scrollbar
    );
  }
}