import 'package:flutter/material.dart';
import 'package:ondamenu/screens/service_products_page.dart';
import 'package:ondamenu/services/firebase_services.dart';

class CategoryTypes extends StatefulWidget {
  final List categoryTypeList;
  final String serviceCategoryName;
  final String serviceCategoryID;
  final String serviceCategoryType;
  final Function(String)? onSelected;
  CategoryTypes({
    required this.categoryTypeList,
    this.onSelected,
    required this.serviceCategoryName,
    required this.serviceCategoryID,
    required this.serviceCategoryType,
  });

  @override
  _CategoryTypesState createState() => _CategoryTypesState();
}

class _CategoryTypesState extends State<CategoryTypes> {
  String? _selectedProductName = "selected-product-name";
  String _selectedProductID = "selected-product-id";
  String _selectedProductSrvcID = "selected-product-service-id";
  String _selectedSrvcCtgryName = "selected-service-name";
  String _selectedSrvcCtgryID = "selected-service-id";
  String _selectedSrvcCtgryType = "selected-service-type";

  bool _isCustomerService = false;
  var slctdSrvc;

  FirebaseServices _firebaseServices = FirebaseServices();

  /*Future _isProductSelected(prodID) {
    return _firebaseServices.usersRef
        .doc(_firebaseServices.getUserID())
        .collection("SelectedService")
        .where('prodID', isEqualTo: prodID)
        .get()
        .then((snapshot) => {
          for (DocumentSnapshot ds in snapshot.docs){
            if(ds.reference.id == prodID ) {
              print("${ds.reference.id } product!")
            } else {
              _selectServiceProduct()
            }
            // ds.reference.update({'isSelected': false})
          },
        });

    // return prod;
      // print("${snapshot.}product unselected!")
  }*/

  Future _selectServiceProduct() async {
      return _firebaseServices.usersRef
          .doc(_firebaseServices.getUserID())
          .collection("SelectedService")
          .doc()
          .set({
        "prodName": _selectedProductName,
        "prodID": _selectedProductID,
        "srvcCtgry": _selectedSrvcCtgryName,
        "srvcCtgryID": _selectedSrvcCtgryID,
        "date": _firebaseServices.setDayAndTime(),
      }).then((_) {
        print(
            "Name: ${_selectedProductName} | ID: ${_selectedProductID} Selected");
        _setProductIsSelected(_selectedProductID);
      });
  }

  Future _selectCustomerService() async {
    return _firebaseServices.customerSrvcsRef
        .doc(_firebaseServices.getUserID())
        .collection("CustomerServices")
        .doc()
        .set({
          "prodName": _selectedProductName,
          "prodID": _selectedProductID,
          "srvcCtgry": _selectedSrvcCtgryName,
          "srvcCtgryID": _selectedSrvcCtgryID,
          "date": _firebaseServices.setDayAndTime(),
        })
        .then((_) {
          print("Name: ${_selectedProductName} | ID: ${_selectedProductID} Selected");
          _setProductIsSelected(_selectedProductID);
        });
  }

  Future _setProductIsSelected(value) async {
    return _firebaseServices.productsRef
        .doc(value)
        .update({"isSelected": true})
        .then((_) {
          // _selectServiceProduct();
          print("selection done");
        });
  }

  // Check if service type for product or customer before requesting data
  Future _checkServiceType() async {
    // widget.categoryTypeList.forEach((element) {
    //   print('the ID: ${element} is a ${widget.serviceCategoryType} type object.');
    // });
    // if( widget.categoryTypeList[0]['srvcType'] == "product")  {
    if( widget.serviceCategoryType == "customer")  {
      _isCustomerService = true;
      // slctdSrvc = _firebaseServices.customerSrvcsRef;
      // print ('this Service ${widget.serviceCategoryName} is a customer service');
    } /*else {
      slctdSrvc = _firebaseServices.productsRef;
      // print ('this service is type: ${widget.serviceCategoryType}');
      // print ('this service is type: ${widget.categoryTypeList[0].data['srvcType']}');
    }*/
  }

  @override
  void initState() {
    // _isCustomerService = true;
    // _isCustomerService = "VnhXnkWdbvbZcSm7duYF";
    _checkServiceType();
    super.initState();
  }


  @override
  Widget build(BuildContext context) {
    // print("amt: ${widget.categoryTypeList.length}");
    // print("srvcType: ${widget.serviceCategoryType}");
    // print("customer srvcType: ${_isCustomerService}");
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: 8,
      ),
      child: GridView.builder(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
              maxCrossAxisExtent: 120,
              childAspectRatio: 2 / 1,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10),
          itemCount: widget.categoryTypeList.length,
          itemBuilder: (BuildContext ctx, index) {
            // if(widget.categoryTypeList.isEmpty){};
            if(_isCustomerService) {
              slctdSrvc = _firebaseServices.customerSrvcsRef;
            } else {
              slctdSrvc = _firebaseServices.productsRef;
            }
            return StreamBuilder(
              stream: slctdSrvc
                  .doc("${widget.categoryTypeList[index]}")
                  .snapshots(),
              builder: (context, AsyncSnapshot productSnap) {

                if(productSnap.connectionState == ConnectionState.active) {
                  if(productSnap.hasData) {
                    // print('has data ${slctdSrvc}');
                    // print('productT: ${productSnap.data["name"]}');
                    print("ID: ${productSnap.data.id} \n Name: ${productSnap.data['name']}");
                    return GestureDetector(
                      onTap: () async {
                        _selectedProductName = await "${productSnap.data['name']}";
                        _selectedProductID = await "${productSnap.data.id}";
                        _selectedProductSrvcID = await "${productSnap.data['srvc']}";
                        _selectedSrvcCtgryName = widget.serviceCategoryName;
                        _selectedSrvcCtgryID = widget.serviceCategoryID;
                        // _prodSelected = true;

                        setState(() {
                          // _isSelected = index;
                        });

                        // print("datentime: ${_firebaseServices.setDayAndTime()}");

                        // await _isProductSelected(productSnap.data.id);
                        await _selectServiceProduct();
                        // await _setProductIsSelected(_selectedProductID);

                        Navigator.push(context, MaterialPageRoute(
                          builder: (context) =>
                              ServiceProductsPage(),
                        ));
                      },
                      child: Container(
                        alignment: Alignment.center,
                        child: FittedBox(
                          fit: BoxFit.fitWidth,
                          child: Text(
                            // "${widget.categoryTypeList[index]}",
                            "${productSnap.data['name']}",
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: productSnap.data['isSelected']
                                  ? Colors.white
                                  : Colors.black,
                              fontSize: 16,
                            ),
                          ),
                        ),
                        decoration: BoxDecoration(
                          color: productSnap.data['isSelected'] ? Theme
                              .of(context)
                              .colorScheme.secondary : Color(0xFFDCDCDC),
                          borderRadius: BorderRadius.circular(8),
                        ),

                      ),
                    );
                  }

                }

                return Scaffold(
                  body: Center(
                    child: CircularProgressIndicator(),
                  ),
                );
              },
            );
          }
      ),
    );
  }
}
