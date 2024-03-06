import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

void main()async{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: FirebaseOptions(apiKey: "AIzaSyAruhVCCom-Vj3_HBJWsDYw2jiwhDwH4Ug", appId: "1:512604174918:android:50a5716a3cf9578d7b6847", messagingSenderId: '', projectId: "cloudstorage-2050a",storageBucket: "cloudstorage-2050a.appspot.com")
  );
  runApp(MaterialApp(home: register(),));
}
class register extends StatefulWidget{
  @override
  State<register> createState() => _registerState();
}

class _registerState extends State<register> {
 var name_controller=TextEditingController();
 var email_controller=TextEditingController();
 late CollectionReference _userCollection;

  @override
  void initState() {
    _userCollection=FirebaseFirestore.instance.collection('user');
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
   return Scaffold(
    appBar: AppBar(title: Text('Firebase Cloud Storage'),),
     body: Padding(
       padding: const EdgeInsets.all(15),
       child: Column(crossAxisAlignment: CrossAxisAlignment.stretch,
         children: [
           TextField(
             controller: name_controller,
             decoration: InputDecoration(labelText: 'Name',border: OutlineInputBorder(borderRadius: BorderRadius.circular(10))),
           ),
           TextField(
             controller: email_controller,
             decoration: InputDecoration(labelText: 'Email',border: OutlineInputBorder(borderRadius: BorderRadius.circular(10))),
           ),
           SizedBox(
             height: 15,
           ),
           ElevatedButton(onPressed: (){
             addUser();
           }, child: Text('Add User')),
           StreamBuilder<QuerySnapshot>(stream: getUser(),
               builder: (context,snapshot){
             if(snapshot.hasError){
               return Text('Error${snapshot.error}');
             }
             if(snapshot.connectionState==ConnectionState.waiting){
               return CircularProgressIndicator();
             }
             final user =snapshot.data!.docs;
             return Expanded(child: ListView.builder(itemCount: user.length,itemBuilder: (context,index){
               final users=user[index];
               final userId=users.id;
               final userName=users['name'];
               final userEmail=users['email'];
               return ListTile(
                 title: Text('$userName',style: TextStyle(fontSize: 15),),
                 subtitle: Text('$userEmail',style: TextStyle(fontSize: 10),),
                 trailing: Wrap(
                   children: [
                     IconButton(onPressed: (){
                       editUser(userId);
                     }, icon: Icon(Icons.edit)),
                     IconButton(onPressed: (){
                       deleteUser(userId);
                       }, icon: Icon(Icons.delete))
                   ],
                 ),
               );
             }));
               }),
         ],
       ),
     ),
   );
  }
  void editUser(var id){
    showDialog(context: context, builder: (context){
      final newname_cntlr=TextEditingController();
      final newemai_cntlr=TextEditingController();
      return AlertDialog(
        title:Text('Update User'),
        content: Column(mainAxisSize: MainAxisSize.min,
          children: [TextField(
            controller: newname_cntlr,
            decoration: InputDecoration(hintText: 'Enter Name',border: OutlineInputBorder()),
          ),
            TextField(
              controller: newemai_cntlr,
              decoration: InputDecoration(hintText: 'Enter Email',border: OutlineInputBorder()),
            )
          ],
        ),
        actions: [
          TextButton(onPressed: (){
            updateUser(id,newname_cntlr.text,newemai_cntlr.text).then((value){
              Navigator.pop(context);
            });
          }, child: Text('update'))
        ],
      );
    });
  }
 ///create user
 Future<void>addUser()async{
    return _userCollection.add({
      'name':name_controller.text,
      'email':email_controller.text
    }).then((value) {
      print('User Added Succesfully');
      name_controller.clear();
      email_controller.clear();
    }).catchError((error){
      print('Failed To add User$error');
    });
 }
 ///read user
 Stream<QuerySnapshot> getUser(){
    return _userCollection.snapshots();
 }
 ///update user
 Future<void>updateUser(var id,String newname,String newemail)async{
    return _userCollection
        .doc(id)
        .update({'name':newname,'email':newemail}).then((value){
          print('user update Succcesfully');
    }).catchError((error){
      print('user data update failed$error');
    });
 }
 ///delete user
 Future<void>deleteUser(var id)async{
    return _userCollection.doc(id).delete().then((value) {
      print('user delete Successfuly');
    }).catchError((error){
      print('user delet failed$error');
    });
 }
}