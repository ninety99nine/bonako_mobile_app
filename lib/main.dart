import 'package:bonako_mobile_app/screens/auth/terms_and_conditions.dart';
import 'package:bonako_mobile_app/providers/instant_carts.dart';
import 'package:bonako_mobile_app/services/localNotificationService.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:bonako_mobile_app/providers/transactions.dart';
import './screens/dashboard/stores/list/stores_screen.dart';
import 'package:bonako_mobile_app/providers/users.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:intro_slider/slide_object.dart';
import 'package:intro_slider/intro_slider.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'screens/auth/password_reset.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import './screens/auth/welcome.dart';
import './screens/auth/signup.dart';
import './providers/locations.dart';
import './screens/auth/login.dart';
import './providers/customers.dart';
import './providers/products.dart';
import './providers/coupons.dart';
import './providers/stores.dart';
import './providers/orders.dart';
import './providers/auth.dart';
import './providers/api.dart';
import 'package:get/get.dart';
import 'dart:convert';

//  Handle received Remote Message (notification) when App is terminated
Future<void> notificationBackgroundHandler(RemoteMessage remoteMessage) async {

  /*
   *  Refer to the Youtube video: https://youtu.be/p7aIZ3aEi2w which i used to setup notifications
   */
  print('Background remoteMessage');

  if(remoteMessage.notification != null){

    print(remoteMessage.notification!.title);
    print(remoteMessage.notification!.body);
    print(remoteMessage.data.toString());

    /**
     *  Force the remoteMessage to pop-up on the screen so that the user is aware that the notification 
     *  came in even while the App is in Foreground mode. This kind of behaviour is called a "Heads-up 
     *  Notification" because the user is being made aware that a new notification was received instead 
     *  of the notification being silently received. Locate the LocalNotificationService Class from the
     *  "/services/LocalNotificationService.dart" to see what the "display" message does. I provided a 
     *  few notes there. Remember that this LocalNotificationService.dart file is a custom file i 
     *  created as well as the Logic in it. The code utilises the "flutter_local_notifications"
     *  plugin to help us show notifications even if we are in Foreground mode by utilizing
     *  a concept called "Channels".
     *
     *  Refer to the Youtube video: https://youtu.be/p7aIZ3aEi2w which i used to setup notifications
     */
    LocalNotificationService.display(remoteMessage);

  }
}

void main() async {

  /**
   *  The WidgetsFlutterBinding.ensureInitialized() is required for Firebase.initializeApp() to
   *  work properly.
   */
  WidgetsFlutterBinding.ensureInitialized();

  //  Connect to Firebase services (So that we can use Firebase Apis e.g Firebase Cloud Messaging)
  await Firebase.initializeApp();

  /**
   *  Create a stream to capture notifications received whilst the App instance is in the background.
   *  Background means that the user opened the App but is not currently interating with it e.g Maybe
   *  the user switched to another App or returned to the device home screen. This stream will 
   *  therefore capture the notification even before the user clicks on the actual notification 
   *  from the notifications tray. We can then use the notification data to extract any
   *  information embedded on the notification.
   * 
   *  The following "FirebaseMessaging.onBackgroundMessage" method requires the handler to be 
   *  a Future Function with the RemoteMessage (the notification message) as the parameter. 
   * 
   *  The handler must be a Top Level Future Function (that is, it must not be inside any class, 
   *  but outside everything) since the "FirebaseMessaging.onBackgroundMessage" works in its own 
   *  isolated scope, which is outside the flutter application scope. This allows the App to
   *  handle the RemoteMessage eventhough if the App is not showing in the foreground.
   * 
   *  Refer to the Youtube video: https://youtu.be/p7aIZ3aEi2w which i used to setup notifications
   */
  FirebaseMessaging.onBackgroundMessage(notificationBackgroundHandler);

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {

    print('Building MyApp');
    
    /**
     *  The "LocalNotificationService" is a custom service we created in the "services" folder.
     *  Its responsible to force notifications to pop-up and show when we are in Foreground
     *  mode. Foreground means that we have the App open and we are interacting with it.
     *  Usually in Foreground mode Flutter does not allow notifications to pop-up and
     *  show, but in our App we want them to show even if the user is using the App.
     * 
     *  We need to run LocalNotificationService.initialize() to setup the service. Then later
     *  we can use the service by running LocalNotificationService.display(remoteMessage)
     *  from the "FirebaseMessaging.onMessage.listen((RemoteMessage remoteMessage)" to
     *  show the remoteMessage (aka Notification) even while we are in Foreground mode.
     * 
     *  Refer to the Youtube video: https://youtu.be/p7aIZ3aEi2w which i used to setup notifications
     */

    LocalNotificationService.initialize(context);

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
         *  ChangeNotifierProvider because the ProductsProvider requires the
         *  LocationsProvider as a dependency. When the LocationsProvider changes,
         *  then the ProductsProvider will also rebuild.
         */
        ChangeNotifierProxyProvider<LocationsProvider, ProductsProvider>(
          create: (_) => ProductsProvider(locationsProvider: LocationsProvider(storesProvider: StoresProvider(authProvider: AuthProvider(apiProvider: ApiProvider())))),
          update: (ctx, locationsProvider, previousProductsProvider) => ProductsProvider(locationsProvider: locationsProvider)
        ),
        /**
         *  Note: We have to use the ChangeNotifierProxyProvider instead of 
         *  ChangeNotifierProvider because the CouponsProvider requires the
         *  LocationsProvider as a dependency. When the LocationsProvider changes,
         *  then the CouponsProvider will also rebuild.
         */
        ChangeNotifierProxyProvider<LocationsProvider, CouponsProvider>(
          create: (_) => CouponsProvider(locationsProvider: LocationsProvider(storesProvider: StoresProvider(authProvider: AuthProvider(apiProvider: ApiProvider())))),
          update: (ctx, locationsProvider, previousCouponsProvider) => CouponsProvider(locationsProvider: locationsProvider)
        ),
        /**
         *  Note: We have to use the ChangeNotifierProxyProvider instead of 
         *  ChangeNotifierProvider because the InstantCartsProvider requires the
         *  LocationsProvider as a dependency. When the LocationsProvider changes,
         *  then the InstantCartsProvider will also rebuild.
         */
        ChangeNotifierProxyProvider<LocationsProvider, InstantCartsProvider>(
          create: (_) => InstantCartsProvider(locationsProvider: LocationsProvider(storesProvider: StoresProvider(authProvider: AuthProvider(apiProvider: ApiProvider())))),
          update: (ctx, locationsProvider, previousInstantCartsProvider) => InstantCartsProvider(locationsProvider: locationsProvider)
        ),
        /**
         *  Note: We have to use the ChangeNotifierProxyProvider instead of 
         *  ChangeNotifierProvider because the UsersProvider requires the
         *  LocationsProvider as a dependency. When the LocationsProvider changes,
         *  then the UsersProvider will also rebuild.
         */
        ChangeNotifierProxyProvider<LocationsProvider, UsersProvider>(
          create: (_) => UsersProvider(locationsProvider: LocationsProvider(storesProvider: StoresProvider(authProvider: AuthProvider(apiProvider: ApiProvider())))),
          update: (ctx, locationsProvider, previousUsersProvider) => UsersProvider(locationsProvider: locationsProvider)
        ),
        /**
         *  Note: We have to use the ChangeNotifierProxyProvider instead of 
         *  ChangeNotifierProvider because the CustomersProvider requires the
         *  LocationsProvider as a dependency. When the LocationsProvider changes,
         *  then the CustomersProvider will also rebuild.
         */
        ChangeNotifierProxyProvider<LocationsProvider, CustomersProvider>(
          create: (_) => CustomersProvider(locationsProvider: LocationsProvider(storesProvider: StoresProvider(authProvider: AuthProvider(apiProvider: ApiProvider())))),
          update: (ctx, locationsProvider, previousCustomersProvider) => CustomersProvider(locationsProvider: locationsProvider)
        ),
        /**
         *  Note: We have to use the ChangeNotifierProxyProvider instead of 
         *  ChangeNotifierProvider because the TransactionsProvider requires the
         *  LocationsProvider as a dependency. When the LocationsProvider changes,
         *  then the TransactionsProvider will also rebuild.
         */
        ChangeNotifierProxyProvider<OrdersProvider, TransactionsProvider>(
          create: (_) => TransactionsProvider(ordersProvider: OrdersProvider(locationsProvider: LocationsProvider(storesProvider: StoresProvider(authProvider: AuthProvider(apiProvider: ApiProvider()))))),
          update: (ctx, ordersProvider, previousTransactionsProvider) => TransactionsProvider(ordersProvider: ordersProvider)
        ),
      ],
      child: GetMaterialApp(
        title: 'Bonako',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          accentColor: Colors.blue,
          //  primarySwatch: kPrimaryColor,
          splashColor: Colors.blue.withOpacity(0.3),
          highlightColor: Colors.blue.withOpacity(0.2),
        ),
        
        home: AppScreen(),
    
        //  initialRoute: '/',
        routes: {
          LoginScreen.routeName: (ctx) => LoginScreen(),
          WelcomePage.routeName: (ctx) => WelcomePage(),
          SignUpScreen.routeName: (ctx) => SignUpScreen(),
          StoresScreen.routeName: (ctx) => StoresScreen(),
          PasswordResetScreen.routeName: (ctx) => PasswordResetScreen(),
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

    /**
     *  Get the Remote Message captured after the user taps on the notification from the notification tray
     *  and open the App from the terminated state. The terminated state means that the App is not 
     *  launched or existing in the background.
     *
     *  Refer to the Youtube video: https://youtu.be/p7aIZ3aEi2w which i used to setup notifications
     */
    FirebaseMessaging.instance.getInitialMessage().then((RemoteMessage? remoteMessage){

      //  Check if the remote message exists
      if( remoteMessage != null ){

        print('Termiated remoteMessage');
        print(remoteMessage);

        print('remoteMessage.notification');
        print(remoteMessage.notification);

        if(remoteMessage.notification != null){
          
          showDialog(context: context, builder: (_){
            return AlertDialog(
              title: Text((remoteMessage.notification!.title as String)),
              content: Text((remoteMessage.notification!.body as String)),
            );
          });

          print(remoteMessage.notification!.title);
          print(remoteMessage.notification!.body);

        }

      }

    });

    /**
     *  Create a stream to capture notifications received whilst the App instance is in the foreground.
     *  Foreground means that the user opened the App and is currently interating with it. This stream
     *  will therefore return any notifications received while the user is actively using the app.
     *
     *  Refer to the Youtube video: https://youtu.be/p7aIZ3aEi2w which i used to setup notifications
     */
    FirebaseMessaging.onMessage.listen((RemoteMessage remoteMessage) { 

      print('Foreground remoteMessage');
      print(remoteMessage);

      print('remoteMessage.notification');
      print(remoteMessage.notification);

      if(remoteMessage.notification != null){

        print(remoteMessage.notification!.title);
        print(remoteMessage.notification!.body);

        /**
         *  Force the remoteMessage to pop-up on the screen so that the user is aware that the notification 
         *  came in even while the App is in Foreground mode. This kind of behaviour is called a "Heads-up 
         *  Notification" because the user is being made aware that a new notification was received instead 
         *  of the notification being silently received. Locate the LocalNotificationService Class from the
         *  "/services/LocalNotificationService.dart" to see what the "display" message does. I provided a 
         *  few notes there. Remember that this LocalNotificationService.dart file is a custom file i 
         *  created as well as the Logic in it. The code utilises the "flutter_local_notifications"
         *  plugin to help us show notifications even if we are in Foreground mode by utilizing
         *  a concept called "Channels".
         *
         *  Refer to the Youtube video: https://youtu.be/p7aIZ3aEi2w which i used to setup notifications
         */
        LocalNotificationService.display(remoteMessage);

      }

    });

    /**
     *  Create a stream to capture notifications received whilst the App instance is in the background.
     *  Background means that the user opened the App but is not currently interating with it e.g Maybe
     *  the user switched to another App or returned to the device home screen. This stream will 
     *  therefore capture the notification only if the user clicks on the actual notification 
     *  from the notifications tray. We can then use the notification data to extract any
     *  information embedded on the notification.
     * 
     *  We had to include the following metadata within the "/android/app/src/main/AndroidManifest.xml":
     * 
     *  <meta-data
     *    android:name="com.google.firebase.messaging.default_notification_channel_id"
     *    android:value="high_importance_channel" 
     *  />
     * 
     *  By default the flutter App did not contain this meta-data, but its important for us to allow our
     *  notification to show as a "Heads-up" notification while in Background mode. Usually in this state, 
     *  when notifications are sent, they are received but the notification summary is not shown to the 
     *  user. That is we don't get a pop-up (Heads-up) of the notification, but when you pull down the
     *  notifications tray, you will see that the notification was received. To force the notificaiton
     *  to show as a "Heads-up" behaviour, we can archieve this by setting up a channel that can be 
     *  used to deliver notifications for "Heads-up" display even if we are in this Background mode.
     * 
     *  We do this by registering the channel from the "AndroidManifest.xml" file and giving the channel
     *  an identifier. I decided to enter "high_importance_channel" as the channel ID (aka identifier) 
     *  to the "android:value". This can be any value you want e.g "bonako_important_channel" or
     *  whatever you want. From the Firebase Cloud Messaging console when creating a notification, the
     *  same channel id must be included on the notification from the "Additional options" section of
     *  the notification. You will see a field called "Android Notification Channel" which is where
     *  the channel id must be inserted. This is an indication that the notification is so important
     *  that even if the notification is received while on Background mode, we must still allow it
     *  to pop-up and show to the user.
     *
     *  Refer to the Youtube video: https://youtu.be/p7aIZ3aEi2w which i used to setup notifications
     */
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage remoteMessage) { 

      print('Background remoteMessage (On Tap)');
      print(remoteMessage);

      print('remoteMessage.notification');
      print(remoteMessage.notification);

      if(remoteMessage.notification != null){

        print(remoteMessage.notification!.title);
        print(remoteMessage.notification!.body);

      }

    });

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

          /**
           * Set if we have an incomplete login process
           */
          await authProvider.setLoginDataFromDevice();

          /**
           * Set if we have an incomplete password reset process
           */
          await authProvider.setPasswordResetDataFromDevice();

          /**
           * Set if we have an incomplete registration process
           */
          await authProvider.setRegistrationDataFromDevice();

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

    //  Check for incomplete login form
    final hasIncompleteLoginForm = authProvider.hasLoginData;

    //  Check for incomplete password reset form
    final hasIncompletePasswordResetForm = authProvider.hasPasswordResetData;

    //  Check for incomplete registration form
    final hasIncompleteRegistrationForm = authProvider.hasRegistrationData;

    //  Check is the user accepted the terms and conditions
    final hasAcceptedTermsAndConditions = authProvider.hasAcceptedTermsAndConditions;

    //  Set default screen
    Widget appScreen = WelcomePage();

    if(isLoading == true){

      appScreen = LoadingScreen();

    }else if(hasViewedIntro == false){

      //  If we have not seen the intro screen
      appScreen = IntroScreen();

    }else if(hasIncompleteLoginForm == true){

      //  If we have an incomplete login form
      appScreen = LoginScreen();

    }else if(hasIncompletePasswordResetForm == true){

      //  If we have an incomplete password reset form
      appScreen = PasswordResetScreen();

    }else if(hasIncompleteRegistrationForm == true){

      //  If we have an incomplete registration form
      appScreen = SignUpScreen();

    }else if((isAuthenticated && hasAuthUser) == true && hasAcceptedTermsAndConditions == false){
      
      //  If we have not accepted terms and conditions
      appScreen = TermsAndConditionsScreen();

    }else if((isAuthenticated && hasAuthUser) == true && hasAcceptedTermsAndConditions == true){

      //  If we are authenticated show the stores
      appScreen = StoresScreen();

    }

    print('hasAuthUser: '+hasAuthUser.toString());
    print('isAuthenticated: '+isAuthenticated.toString());
    print('hasIncompleteLoginForm: '+hasIncompleteLoginForm.toString());
    print('hasIncompletePasswordResetForm: '+hasIncompletePasswordResetForm.toString());
    print('hasIncompleteRegistrationForm: '+hasIncompleteRegistrationForm.toString());
    print('hasAcceptedTermsAndConditions: '+hasAcceptedTermsAndConditions.toString());

    return appScreen;
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

        backgroundOpacity: 0.95,
        backgroundOpacityColor: Colors.blue.shade700,
        backgroundImage: 'assets/images/logo-white-2x.png',
        
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

  ButtonStyle buttonStyle() {
    return ButtonStyle(
      shape: MaterialStateProperty.all<OutlinedBorder>(StadiumBorder()),
      overlayColor: MaterialStateProperty.all<Color>(Color(0x33FFA8B0)),
      backgroundColor: MaterialStateProperty.all<Color>(Color(0x33F3B4BA)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return new IntroSlider(
      
      //  List slides
      slides: this.slides,

      //  Skip button
      renderSkipBtn: this.renderSkipBtn(),
      skipButtonStyle: buttonStyle(),

      //  Next button
      renderNextBtn: this.renderNextBtn(),
      nextButtonStyle: buttonStyle(),

      //  Done button
      renderDoneBtn: this.renderDoneBtn(),
      onDonePress: this.onDonePress,
      doneButtonStyle: buttonStyle(),

      //  Dot indicator
      colorDot: Colors.white.withOpacity(0.2),
      colorActiveDot: Colors.white,
      sizeDot: 13.0,

      //  Show or hide status bar
      hideStatusBar: true,
      backgroundColorAllSlides: Colors.grey,

      // Scrollbar
    );
  }
}