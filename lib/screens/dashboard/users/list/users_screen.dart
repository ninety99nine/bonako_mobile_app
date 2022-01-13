import 'package:bonako_mobile_app/components/custom_instruction_message.dart';
import 'package:bonako_mobile_app/components/custom_tag.dart';
import 'package:bonako_mobile_app/models/locationTotals.dart';
import 'package:bonako_mobile_app/providers/locations.dart';
import 'package:bonako_mobile_app/screens/dashboard/users/show/components/userRoleTag.dart';
import './../../../../screens/dashboard/stores/show/store_screen.dart';
import './../../../../components/custom_rounded_refresh_button.dart';
import './../../../../components/custom_floating_action_button.dart';
import 'package:shared_preferences/shared_preferences.dart';
import './../../../../components/custom_back_button.dart';
import './../../../../components/custom_search_bar.dart';
import './../../../../components/custom_app_bar.dart';
import './../../../../components/custom_button.dart';
import './../../../../components/custom_loader.dart';
import 'package:auto_size_text/auto_size_text.dart';
import '../../../../components/store_drawer.dart';
import './../../../../providers/stores.dart';
import 'package:flutter_svg/flutter_svg.dart';
import './../../../../providers/users.dart';
import './../../../../models/users.dart';
import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import './../../users/show/user.dart';
import 'package:async/async.dart';
import 'package:get/get.dart';
import 'dart:convert';

class UsersScreen extends StatefulWidget {
  @override
  _UsersScreenState createState() => _UsersScreenState();
}

class _UsersScreenState extends State<UsersScreen> {
  bool isLoadingMore = false;
  var cancellableOperation;
  bool isLoading = false;
  var paginatedUsers;
  int currentPage = 1;

  void startLoader({ loadMore: false }){
    if(mounted){
      setState(() {
        loadMore ? isLoadingMore = true : isLoading = true;
      });
    }
  }

  void stopLoader({ loadMore: false }){
    if(mounted){
      setState(() {
        loadMore ? isLoadingMore = false : isLoading = false;
      });
    }
  }

  @override
  void initState() {
    
    fetchUsers();

    super.initState();

  }

  Future<http.Response> fetchUsers({ String searchWord: '', bool loadMore = false, bool resetPage = false, bool refreshContent = false, int limit = 10 }) async {
    
    startLoader(loadMore: loadMore);

    //  If we have a cancellable operation of fetching stores
    if(cancellableOperation != null){
      
      //  Cancel the request of fetching stores
      (cancellableOperation as CancelableOperation).cancel();

    }

    //  If we should load more  
    if(loadMore){

      //  Increment the page to target the next page content
      currentPage++;

    }

    //  If we should reset the page 
    if(resetPage){

      //  Set to target the first page content
      currentPage = 1;

    }

    /**
     *  If we should refresh the content already loaded, then set  
     *  the page equal to 1, otherwise set the current page.
     */
    final page = refreshContent ? 1 : currentPage;

    final usersProvider = Provider.of<UsersProvider>(context, listen: false);

    final apiInstance = (usersProvider.fetchUsers(searchWord: searchWord, page: page, limit: limit, context: context));

    cancellableOperation = CancelableOperation.fromFuture (
      apiInstance,
      onCancel: (){
        cancellableOperation = null;
      }
    );
    
    cancellableOperation.value.then((http.Response response){

      if(response.statusCode == 200 && mounted){

        final responseBody = jsonDecode(response.body);

        setState(() {

          //  If we are loading more users
          if(loadMore == true){

            //  Add loaded users to the list of existing paginated users
            (paginatedUsers as PaginatedUsers).embedded.users.addAll(PaginatedUsers.fromJson(responseBody).embedded.users);

            //  Re-calculate the user count
            (paginatedUsers as PaginatedUsers).count += PaginatedUsers.fromJson(responseBody).count;

            //  Increment the current page
            (paginatedUsers as PaginatedUsers).currentPage = currentPage;

          }else{

            paginatedUsers = PaginatedUsers.fromJson(responseBody);

          }

        });

      }

      return response;

    });
    
    cancellableOperation.value.whenComplete(() {

      stopLoader(loadMore: loadMore);

    });

    return cancellableOperation.value;

  }

  @override
  Widget build(BuildContext context){
    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: Scaffold(
        floatingActionButtonLocation: FloatingActionButtonLocation.miniEndFloat,
        floatingActionButton: CustomFloatingActionButton(
          onAddUser: fetchUsers
        ),
        appBar: CustomAppBar(title: 'Team'),
        drawer: StoreDrawer(),
        body: Content(
          paginatedUsers: paginatedUsers,
          isLoadingMore: isLoadingMore,
          fetchUsers: fetchUsers,
          isLoading: isLoading
        ),
      )
    );
  }
}

class Content extends StatefulWidget {

  final PaginatedUsers? paginatedUsers;
  final Function fetchUsers;
  final bool isLoadingMore;
  final bool isLoading;

  Content({ this.paginatedUsers, required this.isLoadingMore, required this.isLoading, required this.fetchUsers });
  
  @override
  _ContentState createState() => _ContentState();
}

class _ContentState extends State<Content> {
  late ScrollController scrollController;
  List<User> users = [];
  var filterStatus = false;
  var isSearching = false;
  Map activeFilters = {};
  String searchWord = '';
  var isLoading = false;

  void startLoader(){
    if(mounted){
      setState(() {
        isLoading = true;
      });
    }
  }

  void stopLoader(){
    if(mounted){
      setState(() {
        isLoading = false;
      });
    }
  }

  void startSearchLoader(){
    if(mounted){
      setState(() {
        isSearching = true;
      });
    }
  }

  void stopSearchLoader(){
    if(mounted){
      setState(() {
        isSearching = false;
      });
    }
  }

  LocationTotals get locationTotals {
    return Provider.of<LocationsProvider>(context).getLocationTotals;
  }

  @override
  void initState() {

    setUsers();

    getFiltersFromDevice();

    scrollController = new ScrollController()..addListener(_scrollListener);

    super.initState();

  }

  @override
  void dispose() {
    scrollController.removeListener(_scrollListener);
    super.dispose();
  }

  void _scrollListener() {

    //  If we are 100 pixels or less from the scroll bottom
    if (scrollController.position.extentAfter == 0) {

      final paginatedUsers = (widget.paginatedUsers as PaginatedUsers);

      if( widget.isLoading == false && widget.isLoadingMore == false && paginatedUsers.count < paginatedUsers.total){
        
        widget.fetchUsers(searchWord: searchWord, loadMore: true);

      }
      
    }

  }

  @override
  void didUpdateWidget(covariant Content oldWidget) {

    setUsers();
    
    super.didUpdateWidget(oldWidget);

  }

  void setUsers(){

    //  If we have the paginated users
    if( widget.paginatedUsers != null ){

      //  Extract the users
      users = widget.paginatedUsers!.embedded.users;

    }

  }

  Future<http.Response> startSearch({ searchWord: '' }) async {
    if(mounted){
      setState(() {
          this.searchWord = searchWord;
      });
    }
      
    return await widget.fetchUsers(searchWord: searchWord, resetPage: true);
  }

  void navigateToInviteUsers() async {
    
    final usersProvider = Provider.of<UsersProvider>(context, listen: false);

    await usersProvider.navigateToInviteUsers();

    //  Refetch the users as soon as we return
    widget.fetchUsers(resetPage: true);

  }

  void removeUser(int userId, int currNumberOfUsers){

    setState(() {
      users.removeWhere((user) => user.id == userId);
      
      //  If the current number of users is Zero 
      if(currNumberOfUsers == 0){

        //  Fetch the users from the server
        widget.fetchUsers(searchWord: searchWord, resetPage: true);

      }
    });

  }

  void toggleFilterStatus(){
    
    if(mounted){
      setState(() {
        filterStatus = !filterStatus;
      });
    }

  }

  bool get hasUsers {
    return (users.length > 0);
  }

  Future getFiltersFromDevice() async {
    
    await SharedPreferences.getInstance().then((prefs) async {

      final filters = await jsonDecode(prefs.getString('userFilters') ?? '{}');

      updateActiveFilters(filters);

    });

  }

  void updateActiveFilters(Map filters){

    setState(() {

      //  Extract only the active filters
      activeFilters = Map.from(filters)..removeWhere((key, value) => (value == false));

    });

    widget.fetchUsers(searchWord: searchWord, resetPage: true);

  }

  void showFiltersDialog(){

    var alertDialog = (filters, setState, isLoading) {

      bool hasFilters() {
        return filters.length > 0 ? true : false;
      }

      void toggleFilter(filterName) {

        SharedPreferences.getInstance().then((prefs) async {

          setState(() {

            filters[filterName] = !(filters[filterName] as bool);

          });

          //  Store the updated filters
          prefs.setString('userFilters', jsonEncode(filters));

          //  Update the UI active filters
          updateActiveFilters(filters);
          
        });
        
      }

      Widget filterSwitch({ required bool value, required void Function(bool)? onChanged, required String text }){

        return Row(
          children: [
            Switch(
              value: value, 
              onChanged: onChanged
            ),
            Flexible(child: Text(text, style: TextStyle(fontSize: 12),))
          ],
        );

      }

      return AlertDialog(
          title: Text('Team Filters'),
          content: Container(
            height: 320,
            child: Column(
              children: [
                Divider(height: 10,),
                RichText(
                  textAlign: TextAlign.justify,
                  text: TextSpan(
                    style: TextStyle(color: Colors.black, height: 1.5),
                    children: <TextSpan>[
                      TextSpan(text: 'Turn filters '),
                      TextSpan(
                        text: 'on / off', 
                        style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue),
                      ),
                      TextSpan(text: ' to limit users to show.'),
                    ],
                  ),
                ),
                Divider(height: 10,),

                if(isLoading || hasFilters() == false) CustomLoader(),

                if(hasFilters()) filterSwitch(
                  text: 'Show active users',
                  value: filters['active'],
                  onChanged: (status){
                    toggleFilter('active');
                  },
                ),
                if(hasFilters()) filterSwitch(
                  text: 'Show inactive users',
                  value: filters['inactive'],
                  onChanged: (status){
                    toggleFilter('inactive');
                  },
                ),
                if(hasFilters()) filterSwitch(
                  text: 'Show users offering free delivery',
                  value: filters['free delivery'],
                  onChanged: (status){
                    toggleFilter('free delivery');
                  },
                ),
              ],
            ),
          ),
        );
    };

    showDialog(
      context: context, 
      builder: (ctx){
        
        bool isLoading = false;
        bool hasSetFilters = false;

        Map defaultFilters = {
          'active' : false,
          'inactive' : false,
          'free delivery' : false,
        };

        Map filters = {};

        Future setFiltersFromDevice(setState) async {

          setState(() {
            isLoading = true;
          });

          filters = await SharedPreferences.getInstance().then((prefs) async {

            var userFilters = prefs.getString('userFilters');

            //  If we have no user filters
            if(userFilters == null){

              //  Store the default filters
              prefs.setString('userFilters', jsonEncode(defaultFilters));

              //  return the default filters
              return defaultFilters;
              
            }else{
              
              //  Get the filters stored on the device
              final Map storedFilters = jsonDecode( prefs.getString('userFilters') ?? '{}');

              //  Merge the default filters with the stored filters
              final mergedFilters = {
                ...defaultFilters,
                ...storedFilters,
              };

              /**
               *  If the number of default filters and the number of stored filters
               *  are not the same, then it means that the filters must be re-stored
               *  as merged filters
               */
              if(defaultFilters.length != storedFilters.length){

                //  Store the default filters merged with the stored filters
                await prefs.setString('userFilters', jsonEncode(mergedFilters));

              }

              return mergedFilters;

            }

          }).whenComplete((){
            setState(() {
              isLoading = false;
              hasSetFilters = true;
            });
          });

        }

        return StatefulBuilder(
          builder: (context, setState) {

            if(hasSetFilters == false) setFiltersFromDevice(setState);

            return alertDialog(filters, setState, isLoading);
          }
        );
      }
    );

  }

  bool get hasActiveFilters {
    return activeFilters.length > 0;
  }

  bool get hasSearchWord {
    return searchWord != '';
  }

  @override
  Widget build(BuildContext context) {

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 10, vertical: 20),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              CustomBackButton(fallback: (){
                Get.offAll(() => ShowStoreScreen());
              }),
              CustomRoundedRefreshButton(onPressed: (){
                
                if(widget.paginatedUsers == null){

                  widget.fetchUsers(searchWord: searchWord, resetPage: true);

                }else{

                  /**
                   *  If the total number of users exceeds the per page limit, then request that we 
                   *  refetch the same number of users e.g If we limit by 10 per page, but we already 
                   *  loaded 20, then we should still load 20 when we refresh instead of the 10 limit.
                   */
                  final limit = (widget.paginatedUsers!.count > widget.paginatedUsers!.perPage) ? widget.paginatedUsers!.count : widget.paginatedUsers!.perPage;

                  widget.fetchUsers(searchWord: searchWord, refreshContent: true, limit: limit);

                }

              }),
            ],
          ),
          Divider(),

          Expanded(
            child: SingleChildScrollView(
              controller: scrollController,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
          
                  if(hasUsers || isSearching || searchWord != '') Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                
                      //  Search Bar
                      Expanded(
                        child: CustomSearchBar(
                          labelText: 'Search users',
                          helperText: 'Search using user name',
                          onSearch: (searchWord){
                            startSearchLoader();
                            return startSearch(searchWord: searchWord).whenComplete(() => stopSearchLoader());
                          }
                        ),
                      ),
                      
                      //  Popup Menu
                      /*
                      PopUpMenu(
                        showFiltersDialog: showFiltersDialog,
                        updateActiveFilters: updateActiveFilters
                      )
                      */

                    ],
                  ),
          
                  SizedBox(height: 10,),
  
                  //  Filters
                  if((isLoading == false && widget.isLoading == false && isSearching == false) && locationTotals.userTotals.total > 0)
                    FilterTag(
                      activeFilters: activeFilters,
                      showFiltersDialog: showFiltersDialog,
                    ),

                  if((isLoading == false && widget.isLoading == false) && hasUsers == true) Column(
                    children: [
                      Divider(),

                      if(hasSearchWord && widget.paginatedUsers != null) 
                        CustomInstructionMessage(text: 'Showing '+widget.paginatedUsers!.count.toString()+' / '+widget.paginatedUsers!.total.toString()+' matches'),

                      if(isSearching == false && hasActiveFilters == false)
                        CustomInstructionMessage(text: 'Swipe any user to the right to delete'),

                      if(isSearching == false && hasSearchWord == false && hasActiveFilters == true) 
                        CustomInstructionMessage(text: 'Filters have been added to limit users'),

                      Divider()
                    ],
                  ),

                  //  Loader
                  if(isLoading == true || widget.isLoading == true) CustomLoader(topMargin: 100),
                  
                  //  User list
                  if((isLoading == false && widget.isLoading == false) && hasUsers == true)
                    UserList(
                      paginatedUsers: widget.paginatedUsers!,
                      isLoadingMore: widget.isLoadingMore,
                      fetchUsers: widget.fetchUsers,
                      removeUser: removeUser,
                      searchWord: searchWord,
                      users: users,
                    ),
          
                  //  No users found
                  if((isLoading == false && widget.isLoading == false && isSearching == false) && hasUsers == false && hasSearchWord == false)
                    NoUsersFound(
                      navigateToInviteUsers: navigateToInviteUsers
                    ),
          
                  //  No users found
                  if((isLoading == false && widget.isLoading == false && isSearching == false) && hasUsers == false && hasSearchWord == true)
                    NoSearchedUsersFound(
                      searchWord: searchWord,
                      navigateToInviteUsers: navigateToInviteUsers
                    ),
                ],
              )
            ),
          )
        ],
      ),
    );
  }
}

class FilterTag extends StatelessWidget {
  
  final activeFilters;
  final Function showFiltersDialog;

  FilterTag({ required this.activeFilters, required this.showFiltersDialog });

  bool get hasActiveFilters {
    return activeFilters.length > 0;
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        if(hasActiveFilters) GestureDetector(
          onTap: (){
            showFiltersDialog();
          },
          child: Container(
            margin: const EdgeInsets.symmetric(vertical: 10.0),
            padding: const EdgeInsets.only(top: 5, bottom: 5, left: 5, right: 20),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.blue.shade200)
            ),
            child: Wrap(
              children: [
                CircleAvatar(
                  radius: 10,
                  backgroundColor: Colors.blue.withOpacity(0.3),
                  child: Text(activeFilters.length.toString(), style: TextStyle(fontSize: 12, color: Colors.blue.shade900)),
                ),
                SizedBox(width: 10),
                Padding(
                  padding: const EdgeInsets.only(top: 2.0),
                  child: Text('Filters'),
                ),
              ],
            ),
          ),
        ),
        TextButton(
          onPressed: (){
            showFiltersDialog();
          }, 
          child: Row(
            children: [
              Icon(hasActiveFilters ? Icons.edit : Icons.add, size: 14),
              SizedBox(width: 5),
              Text(hasActiveFilters ? 'Edit' : 'Add Filter'),
            ],
          )
        )
      ],
    );
  }
}

class PopUpMenu extends StatelessWidget {
  final Function showFiltersDialog;
  final Function updateActiveFilters;

  PopUpMenu({ required this.showFiltersDialog, required this.updateActiveFilters });

  customPopupMenuItem({ required int value, required String text, required icon, required Function()? onTap, required BuildContext context }){
    return 
      PopupMenuItem<int>(
        value: value,
        child: GestureDetector(
          onTap: onTap,
          child: Container(
            width: double.infinity,
            child: Row(
              children: [
                icon,
                const SizedBox(width: 7),
                Text(text)
              ],
            ),
          ),
        )
      );
  }

  @override
  Widget build(BuildContext context) {
    
    return 
      PopupMenuButton<int>(
        icon: Icon(Icons.more_vert),
        offset: Offset(0, 40),
        color: Colors.white,
        itemBuilder: (context) => [
          customPopupMenuItem(
            value: 1,
            text: 'Filters',
            context: context,
            onTap: (){
              Navigator.of(context).pop();
              showFiltersDialog();
            },
            icon: SvgPicture.asset('assets/icons/ecommerce_pack_1/finger.svg', width: 18),
          )
        ]
      );
  }
}

class NoUsersFound extends StatelessWidget {

  final Function navigateToInviteUsers;

  NoUsersFound({ required this.navigateToInviteUsers });

  @override
  Widget build(BuildContext context) {
    
    final storesProvider = Provider.of<StoresProvider>(context, listen: false);
    final store = storesProvider.store;
    
    return Column(
      children: [
        SizedBox(height: 30),
        Container(
          padding: EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.blue.shade50,
            borderRadius: BorderRadius.circular(100),
            border: Border.all(color: Colors.blue.shade100, width: 1),
          ),
          child: SvgPicture.asset('assets/icons/ecommerce_pack_1/employee-badge-1.svg', color: Colors.blue, width: 40,)
        ),
        
        SizedBox(height: 30),

        Text('No members found', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue),),
        
        SizedBox(height: 30),

        AddTeamButton(
          navigateToInviteUsers: navigateToInviteUsers,
        ),

        SizedBox(height: 30),

        Padding(
          padding: const EdgeInsets.all(20),
          child: RichText(
            text: TextSpan(
              style: TextStyle(color: Colors.black, height: 1.5),
              children: <TextSpan>[
                TextSpan(text: 'Add team members to help you manage '),
                TextSpan(
                  text: store.name,
                  style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue),
                  recognizer: TapGestureRecognizer()
                    ..onTap = () {
                      storesProvider.launchVisitShortcode(store: store, context: context);
                    }),
                TextSpan(text: ' and become more productive.'),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class NoSearchedUsersFound extends StatelessWidget {

  final String searchWord;
  final Function navigateToInviteUsers;

  NoSearchedUsersFound({ required this.searchWord, required this.navigateToInviteUsers });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Divider(),
          Container(
            padding: EdgeInsets.all(20),
            margin: EdgeInsets.only(top: 20),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(100),
              border: Border.all(color: Colors.blue.shade100, width: 1),
            ),
            child: SvgPicture.asset('assets/icons/ecommerce_pack_1/employee-badge-1.svg', color: Colors.blue, width: 40,)
          ),
          SizedBox(height: 30),
          Text('No search results', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue),),
        
          SizedBox(height: 30),
          AddTeamButton(
            navigateToInviteUsers: navigateToInviteUsers,
          ),

          SizedBox(height: 30),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                RichText(
                  textAlign: TextAlign.center,
                  text: TextSpan(
                    style: TextStyle(color: Colors.black, height: 1.5),
                    children: <TextSpan>[
                      TextSpan(text: 'We could not find any team members matching the keyword '),
                      TextSpan(
                        text: searchWord, 
                        style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue),
                      )
                    ],
                  ),
                ),
              ],
            ),
          ),
          Divider(),
        ]
      ),
    );
  }
}

class AddTeamButton extends StatelessWidget {

  final Function navigateToInviteUsers;

  AddTeamButton({ required this.navigateToInviteUsers });

  @override
  Widget build(BuildContext context) {

    return CustomButton(
      width: 300,
      text: '+ Add Team',
      onSubmit: () async {

        navigateToInviteUsers();

      }, 
    );
  }
}

class UserList extends StatelessWidget {
  final PaginatedUsers paginatedUsers;
  final Function fetchUsers;
  final Function removeUser;
  final List<User> users;
  final bool isLoadingMore;
  final searchWord;

  UserList({ 
    required this.paginatedUsers, required this.users, required this.removeUser,
    required this.fetchUsers, required this.isLoadingMore, required this.searchWord
  });

  @override
  Widget build(BuildContext context) {

    Widget buildUserListView(List<User> users){

      var currNumberOfUsers = users.length;

      return ListView.builder(
        shrinkWrap: true,
        physics: NeverScrollableScrollPhysics(),
        itemCount: users.length,
        itemBuilder: (ctx, index){

          final user = users[index];
          final userCard = UserCard(user: user, searchWord: searchWord, fetchUsers: fetchUsers);

          return Dismissible(
            key: ValueKey(user.id),
            direction: DismissDirection.startToEnd,
            confirmDismiss: (dismissDirection) async {
              final bool isDeleted = await Provider.of<UsersProvider>(context, listen: false).handleDeleteUser(
                user: user, 
                context: ctx
              //  Default to false if null value
              ) ?? false;

              if( isDeleted ){

                //  Decrement the current number of users by one
                currNumberOfUsers--;

                //  Remove the user from the list of users
                removeUser(user.id, currNumberOfUsers);

              }

              //  Determine whether to dismiss the user card
              return isDeleted;

            },
            child: userCard,
            background: Container(
              color: Colors.red.shade100,
              alignment: Alignment.centerLeft,
              padding: EdgeInsets.only(left: 20),
              child: Icon(Icons.delete, color: Colors.red)
            ),
          );
        }
      );

    }

    return 
      Column(
        children: [
          buildUserListView(users),
          SizedBox(height: 40),
          if(paginatedUsers.count < paginatedUsers.total && isLoadingMore == true) CustomLoader(),
          if(paginatedUsers.count == paginatedUsers.total && isLoadingMore == false) Text('No more users'),
          SizedBox(height: 60),
        ],
      );

  }
}

Widget showForwardArrow(){
  return GestureDetector(
    onTap: () => {},
    child: Container(
      margin: EdgeInsets.only(right: 10),
      child: Icon(Icons.arrow_forward, color: Colors.grey,)
    )
  );
}

class UserCard extends StatelessWidget {

  final User user;
  final String searchWord;
  final Function fetchUsers;

  UserCard({ required this.user, required this.searchWord, required this.fetchUsers });

  Widget tag({ required text, boldedText: '', color: Colors.green }){
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
      decoration: BoxDecoration(
        color: color.shade50,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.shade200)
      ),
      child: (text is Widget) ? text : RichText(
        text: TextSpan(
          style: TextStyle(color: color),
          children: <TextSpan>[
            TextSpan(text: text, style: TextStyle(fontSize: 12, color: color ),),
            if(boldedText != '') TextSpan(text: boldedText, style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
          ],
        ),
      )
    );
  }

  @override
  Widget build(BuildContext context) {

    final usersProvider = Provider.of<UsersProvider>(context, listen: false);

    return Card(
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 10, bottom: 10, left: 15, right: 0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  flex: 2,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 5),
                
                      //  User name
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Flexible(
                            child: AutoSizeText(
                              user.attributes.name,
                              maxLines: 2,
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                          )
                        ]
                      ),
                      SizedBox(height: 10),
                      Container(
                        width: double.infinity,
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [

                            //  User role
                            UserRoleTag(user: user),

                            SizedBox(width: 10,),

                            //  User mobile number
                            Text(user.mobileNumber.number, style: TextStyle(color: Colors.grey))
                          ],
                        )
                      ),
                    ],
                  ),
                ),
                Row(
                  children: [
                    
                    //  Forward Arrow 
                    showForwardArrow(),

                  ],
                )
              ],
            ),
          ),
          Material(
            color: Colors.transparent,
            child: InkWell(
              splashColor: Colors.blue.withOpacity(0.2),
              highlightColor: Colors.blue.withOpacity(0.2),
              child: Ink(
                height: 80,
                width: double.infinity
              ),
              onTap: () async {
                  
                //  Set the selected user on the UsersProvider
                usersProvider.setUser(user);

                await Get.to(() => ShowUserScreen());

                //  Refetch the users as soon as we return back
                fetchUsers(searchWord: searchWord, resetPage: true);

              }, 
            )
          )
        ]
      )
    );
  }
}