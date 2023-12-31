import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:ondamenu/services/firebase_services.dart';
import 'package:ondamenu/widgets/product_viewer.dart';
import 'package:ondamenu/widgets/action_bar.dart';

class ServiceProductsPage extends StatefulWidget {
  final Function? onPressed;
  ServiceProductsPage({this.onPressed});

  @override
  _ServiceProductsPageState createState() => _ServiceProductsPageState();
}

class _ServiceProductsPageState extends State<ServiceProductsPage> {
  FirebaseServices _firebaseServices = FirebaseServices();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          StreamBuilder<QuerySnapshot>(
            // get all selected documents from SelectedService
            stream: _firebaseServices.usersRef
                .doc(_firebaseServices.getUserID())
                .collection("SelectedService")
                .orderBy("date", descending: true)
                .snapshots(),
            builder: (context, AsyncSnapshot snapshot) {
              /*if( snapshot.hasError) {
                return Scaffold(
                  body: Center(
                    child: Text("Error: ${snapshot.error}"),
                  ),
                );
              }*/

              if(snapshot.connectionState == ConnectionState.active) {
                if(snapshot.hasData){
                    List _prodData = snapshot.data.docs;
                    // print("prodID: ${_prodData[0].id}");
                    // Collect Selected docs into array / ListView
                    // display data in listview
                    return ListView.builder (
                      itemCount: _prodData.length,
                        itemBuilder: (BuildContext context, int index) {
                          return Container(
                              /*padding : EdgeInsets.only(
                                top: 10,
                                bottom: 20,
                              ),*/
                              // children: [
                              // children: _prodData.map((prodData, index) =>
                              ///// for (var i = 0; i < _prodData.length; i++)
                                // seperate array into individual documents
                              child: ProductViewer(
                                  isSelected: index == 0,
                                  prodID: _prodData[index]['prodID'],
                                  prodName: _prodData[index]['prodName'],
                                  prodSrvcID: _prodData[index]['srvcCtgryID'],
                                  prodSrvcName: _prodData[index]['srvcCtgry'],
                                  // prodSellers: [''],
                                  srvcProdID: _prodData[index].id,
                                )
                            // ]
                          );
                        },

                    );
                  }
                }

              return Scaffold(
                body: Center(
                  child: CircularProgressIndicator(),
                ),
              );
            }
          ),
          ActionBar(
            title: "Service Products",
            hasTitle: true,
            hasBackArrow: true,
          ),
        ],
      ),
    );
  }
}
