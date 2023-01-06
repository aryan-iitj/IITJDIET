import 'dart:ffi';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter/material.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
//import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:alphabet_list_scroll_view/alphabet_list_scroll_view.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:firebase_database/firebase_database.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:path_provider/path_provider.dart';
import 'package:toast/toast.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
//import 'package:charts_flutter/flutter.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:syncfusion_flutter_charts/sparkcharts.dart';
import 'package:date_format/date_format.dart';
import 'package:intl/intl.dart';
import 'fetch_data.dart' as globals;
import 'package:flutter_full_pdf_viewer/flutter_full_pdf_viewer.dart';



void main() async {

  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(
      const MaterialApp(
        home: Home(),
      )
  );
}

class Home extends StatelessWidget {
  const Home({super.key});
  Future<void> Temp() async {
    var headers = {
      'Content-Type': 'text/plain'
    };
    var request = http.Request('GET', Uri.parse('http://harsh1111.pythonanywhere.com/ALL/'));
    request.body = '''{\r\n\t"name" : "sheep, liver",\r\n\t"quantitiy" : "4"\r\n}''';
    request.headers.addAll(headers);
    http.StreamedResponse response = await request.send();
    var x;
    if (response.statusCode == 200) {
      final resp = await response.stream.bytesToString();
      var x = json.decode(resp) as Map<String, dynamic>;
      print(x["Histidine"]);
      x.forEach((nutrient, value) {
        print(nutrient);
        print(value);
      });
    }
    else {
      print(response.reasonPhrase);
    }
  }

  Future<void> writeData2(List<String> patients) async{
    var url = "https://foodapp-5369f-default-rtdb.firebaseio.com/NutrientInfo.json";
    //List<String> patients=[];
    final response = await http.get(Uri.parse(url));
    //final response = http.get(Uri.parse(url));
    final extractedData = json.decode(response.body) as Map<String, dynamic>;
      //print(extractedData);
    if (extractedData == null) {
      return ;
    }
    extractedData.forEach( (key, value) {
      //print(value["PatientId"]);
      //print(patients);
      patients.add(value["PatientId"]);
    });
    //return patients;

  }

  void writeData() async {

  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("IITJ Diet"),
        centerTitle: true,
        backgroundColor: Colors.blue[300],
      ),
      body: Center(
        child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Image.asset("assests/Logo.jpg"),
              Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.fromLTRB(8.0, 26.0, 8.0, 8.0),
                      child: ElevatedButton(
                          onPressed: () {
                            Temp();
                            writeData();
                            Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => DROptions())
                            );
                          },
                          child: Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Column(
                              children: const <Widget>[
                                Icon(Icons.view_list),
                                Text("Fill DR Form"),
                              ],
                          ),
                      ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(8.0, 26.0, 8.0, 8.0),
                      child: ElevatedButton(
                          onPressed: () {
                            //Temp();
                            List<String> patientlist=[];
                            writeData2(patientlist);
                            print(patientlist);

                            Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => DataAnalyze(patientlist: patientlist))
                            );
                          },
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(
                              children: const <Widget>[
                                Icon(Icons.insights),
                                Text("Analyze"),
                        ],
                          ),
                          ),
                      ),
                    ),
                    ],
              ),
            ]
        ),
      ),
    );
  }
}

class DROptions extends StatelessWidget{
  DROptions({super.key});
  final _formKey = GlobalKey<FormBuilderState>();
  DateTime dateRecall = DateTime.now();
  bool cheatMeal = false;
  List<String> foodItems = [];
  List<String>ingredients=[];
  final DateFormat formatter = DateFormat('yyyy-MM-dd');
  String formatted = "";
  //var formatter = new DateFormat('yyyy-MM-dd');
  Future<void> readData() async {
    foodItems.clear();
    var url = "https://foodapp-5369f-default-rtdb.firebaseio.com/Fooditems.json";
    try {
      final response = await http.get(Uri.parse(url));
      //print(response.body);
      final extractedData = json.decode(response.body) as Map<String, dynamic>;
      //print(extractedData);
      print(extractedData);
      if (extractedData == null) {
        return;
      }
      extractedData.forEach((foodId, foodName) {
        // print("Food: ");
        // print(foodName['itemName']);
        foodItems.add(foodName["itemName"]);
      });
      // print("List:");
      //print(foodItems);
    } catch (error) {
      throw error;
    }
  }

  Future<void> readIngredient() async {
    ingredients.clear();
    var url = "https://foodapp-5369f-default-rtdb.firebaseio.com/Ingredient.json";
    try {
      final response = await http.get(Uri.parse(url));

      final extractedData = json.decode(response.body) as Map<String, dynamic>;
      print(extractedData);
      if (extractedData == null) {
        return;
      }
      extractedData.forEach((InId, IngName) {

        ingredients.add(IngName["IngName"]);
      });
    } catch (error) {
      throw error;
    }
  }

  Future<void> writeDataPatient() async {

    var url = "https://foodapp-5369f-default-rtdb.firebaseio.com/PatientDetails.json";

    // (Do not remove “data.json”,keep it as it is)
    try {
      final response = await http.post(
        Uri.parse(url),
        body: json.encode(
            {
              "-01":{"IngName": "Banana", "IngQ": 10},
              "-02":{"IngName": "Wheat", "IngQ": 53},
              "-03":{"IngName": "Rice", "IngQ": 67},
              "-04":{"IngName": "Cucumber", "IngQ": 40},
              "PatientId": "p03",
              "PatientName": "Gaitonde",
              "dateTime": "16-09-22 19-45-02",

            }
        ),
      );
    } catch (error) {
      throw error;
    }
  }
  String p = "";


  @override
  Widget build(BuildContext context){
    return Scaffold(
        appBar: AppBar(
          title: const Text("IITJ Diet"),
          centerTitle: true,
          backgroundColor: Colors.blue[300],
        ),
        body: Padding(
          padding: const EdgeInsets.fromLTRB(16.0, 20.0, 16.0, 8.0),
          child: FormBuilder(
            key: _formKey,
            child:ListView(
              children: <Widget>[
                const Text("\n\nEnter the patient Id: "),
                FormBuilderTextField(name: "Patient"),
                FormBuilderCheckbox(
                  name: "cheatmeal",
                  title: const Text("Was Today a usual day? \nक्या आज का दिन सामान्य था ?"),
                ),


                ElevatedButton(
                    onPressed: (){
                      p = _formKey.currentState!.fields['Patient']!.value.toString();
                      bool chk = true;
                      if(chk){
                        if(_formKey.currentState!.fields['cheatmeal']!.value != null){
                          cheatMeal = _formKey.currentState!.fields['cheatmeal']!.value;
                        }
                        if(cheatMeal == false){
                          showDialog(
                              context: context,
                              builder: (ctx) => AlertDialog(
                                title: const Text("Your day was not a usual one!\n आपका दिन सामान्य नहीं था !"),
                                content: const Text("Please only fill the recall if your diet was a usual diet.\n कृपया रिकॉल केवल तभी भरें जब आपका आहार सामान्य आहार था। "),
                                actions: <Widget>[
                                  ElevatedButton(
                                      onPressed: () {
                                        Navigator.of(ctx).pop();
                                      },
                                      child: const Text("Ok")
                                  )
                                ],
                              )
                          );
                          return;
                        }
                        showDialog(
                            context: context,
                            builder: (ctx) => AlertDialog(
                              insetPadding: const EdgeInsets.symmetric(horizontal: 100),
                              title: const Text("Please wait"),
                              actions: <Widget>[
                                Center(
                                    child: Image.asset(
                                      "assests/Loading.gif",
                                      height: 50,
                                      width: 50,
                                    )
                                ),
                              ],
                            )
                        );
                        dateRecall = DateTime.now();
                        print("date: ");
                        formatted = formatter.format(dateRecall);
                        print(formatted);
                        readData().then((value)=>{
                          print(foodItems),
                          foodItems.sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase())),
                          readIngredient().then((value) =>{
                            print(ingredients),
                            globals.foodItemDisplayList.clear(),
                            globals.ingMap.clear(),
                            ingredients.sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase())),
                            //_formKey.currentState!.fields['currdate']!.save(),
                            _formKey.currentState!.fields['cheatmeal']!.save(),
                            Navigator.of(context).pop(),
                            Navigator.push(

                                context,
                                //MaterialPageRoute(builder: (context) => DRForm(dateRecall: formatted, cheatMeal: cheatMeal, foodItems: foodItems, ingredients: ingredients, namePatient: p))
                                MaterialPageRoute(builder: (context) => FoodDetails(dateRecall: formatted, foodItems: foodItems, ingredients: ingredients, namePatient: p))
                            )
                          })});
                      }
                      else{
                        return;
                      }
                    },
                    child: const Text("Proceed to DR Form")
                ),
              ],
            )
        ),
        ),

    );
  }
}

class DropMenuItem {
  DropMenuItem(this.value, this.image);
  final String value;
  final String image;
}

class FoodDetails extends StatefulWidget{
  FoodDetails({Key? key, required this.dateRecall, required this.foodItems, required this.ingredients, required this.namePatient}) : super(key: key);
  final List<String> foodItems;
  final List<String>ingredients;
  final String dateRecall;
  final String namePatient;
  @override
  _FoodDetailsState createState() => _FoodDetailsState();
}

class _FoodDetailsState extends State<FoodDetails> {
  final String firstexpansion="Select meal time";
  final String thirdexpansion= "Enter Food Item";
  final String otherTile = "If food item is not in list";
  String foodItemSelected = "";
  String recipeName = "";
  List<String> mealName = ['Breakfast', 'Between breakfast and lunch', 'Lunch', 'Between lunch and dinner', 'Dinner', 'After Dinner'];
  List<String> recipeFoods = [
    "Jodhpuri Aloo", "Aloo Tomato vegetable",
    "Tea", "Daal", "Rice", "Rice with Rajma", "Roti",
    "Salad", "Kofta", "Bhindi", "Tori ki sabji"
  ];
  Map<String, Map<String,String>> recipes = {
    "Jodhpuri Aloo": {"potato, brown skin, small": "500.0", "chillies, red": "5.0", "cumin seeds": "4.2", "asafoetida": "1.05", "turmeric powder": "2.1", "coriander leaves": "8.4"},
    "Aloo Tomato vegetable": {"potato, brown skin, big": "83.33", "tomato, ripe, local": "66.67", "onion, big": "33.33", "cumin seeds": "0.714", "turmeric powder": "0.336", "coriander leaves": "1.386", "peas, fresh": "62.5"},
    "Tea": {"milk, whole, cow": "250.0"},
    "Daal": {"green gram, dal": "62.50", "onion, big": "32.5", "tomato, ripe, local": "62.5", "cumin seeds": "1.05", "ginger, fresh": "2.1", "turmeric powder": "0.252", "asafoetida": "0.252"},
    "Rice": {"rice, raw, milled": "60"},
    "Rice with Rajma": {"rice, raw, milled": "60", "rajmah, red": "62.5", "onion, big": "62.5", "tomato, ripe, local": "95.0", "coriander leaves": "1.596", "cumin seeds": "0.798", "turmeric powder": "0.252"},
    "Roti": {"wheat flour, atta": "20.0"},
    "Salad": {"cucumber, green, short": "95.0", "carrot, orange": "62.5", "onion, big": "32.5", "tomato, ripe, local": "32.5", "beet root": "32.5", "cabbage, green": "32.5"},
    "Kofta": {"bottle gourd, elongate, pale green": "200.0", "tomato, ripe, local": "66.67", "onion, big": "33.33", "cumin seeds": "0.714", "turmeric powder": "0.336"},
    "Bhindi": {"ladies finger": "83.33", "onion, big": "83.33", "tomato, ripe, local": "83.33"},
    "Tori ki sabji": {"ridge gourd": "250.0", "tomato, ripe, local": "62.5", "onion, big":"62.5"}
    };
  final _formKey = GlobalKey<FormBuilderState>();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("IITJ Diet"),
        centerTitle: true,
        backgroundColor: Colors.blue[300],
      ),
      body: FormBuilder(
        key: _formKey,
        child: ListView(
          children: <Widget>[
            Card(
              //const Text("")
              elevation: 50,
              shadowColor: Colors.white,
              color: Colors.blueAccent,
              shape:  const RoundedRectangleBorder(
                side: BorderSide(
                  color: Colors.blueAccent,
                  width: 3.0,
                ),),
              child: Card(
                      elevation: 100,
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(8.0, 8.0, 8.0, 8.0),
                        child: FormBuilderDropdown<String>(
                        name: 'mealType',
                        dropdownColor: Colors.white,
                        borderRadius: const BorderRadius.all(
                            Radius.circular(20)),
                        menuMaxHeight: 200,
                        //style: TextStyle(color: Colors.black45, fontSize: 20.0),
                        itemHeight: 50,
                        validator: FormBuilderValidators.required(errorText: "This field is required"),
                        //initialValue: 'Breakfast',
                        decoration: InputDecoration(
                          labelText: '   Select a meal',
                          alignLabelWithHint: true,
                          labelStyle: const TextStyle(
                              color: Colors.black
                          ),
                          suffix: IconButton(
                            icon: const Icon(Icons.close),
                            onPressed: () {
                              _formKey.currentState!.fields['mealType']
                                  ?.reset();
                            },
                          ),
                          hintText: 'Select Meal',
                        ),
                        items: mealName
                            .map((mealType) => DropdownMenuItem(
                          alignment: AlignmentDirectional.center,
                          value: mealType,

                          child: Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                mealType,

                                style: const TextStyle( color: Colors.black, fontSize: 16, fontWeight: FontWeight.bold),
                              )),
                        ))
                            .toList(),
                      ),
                      ),



                    ),
        ),
            const SizedBox(
              //Use of SizedBox
              height: 20,
            ),
            Card(
              elevation: 50,
              shadowColor: Colors.white,
              color: Colors.white,
              shape:  const RoundedRectangleBorder(
                side: BorderSide(
                  color: Colors.blueAccent,
                  width: 3.0,
                ),),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: DropdownSearch<String>(
                    popupProps: const PopupProps.menu(
                      showSearchBox: true,
                      showSelectedItems: true,
                    ),
                    items: widget.foodItems,
                    dropdownDecoratorProps: const DropDownDecoratorProps(
                      dropdownSearchDecoration: InputDecoration(
                        labelText: "Enter Food Item",
                        labelStyle: TextStyle(
                          color: Colors.black,
                          fontSize: 16,
                        ),
                        hintText: "Food Items",
                      ),
                    ),
                    onChanged: (val){
                      foodItemSelected = val.toString();
                      print(foodItemSelected);
                    },
                  ),
              ),
            ),

            const SizedBox(
              //Use of SizedBox
              height: 150,
            ),
            Text("Your Submitted Food Items:\n"),
            Row(

              children: globals.foodItemDisplayList,
            ),
            ElevatedButton(
                onPressed: (){
                  setState(() {
                    globals.foodItemDisplayList.add(Text(foodItemSelected+' '));
                  });
                  List<String> pref = [];
                  if(recipes.containsKey(foodItemSelected)){
                    recipes[foodItemSelected]!.forEach((key, value) {
                      pref.add(key);
                    });
                  }
                  for(int i = 0;i<widget.ingredients.length;i++){
                    if(pref.contains(widget.ingredients[i])) continue;
                    pref.add(widget.ingredients[i]);
                  }
                  _formKey.currentState!.save();
                  Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => IngredientDetails(dateRecall: widget.dateRecall, ingredients: pref, namePatient: widget.namePatient, itmName: foodItemSelected))
                  );
                },
                child: const Text("Enter Ingredient Details")
            ),
          ],
        ),
      ),
    );
  }
}

class IngredientDetails extends StatelessWidget {
  IngredientDetails({Key? key, required this.dateRecall, required this.ingredients, required this.namePatient, required this.itmName}) : super(key: key);
  final String dateRecall;
  final List<String>ingredients;
  final String namePatient;
  final String itmName;
  final _formKey1 = GlobalKey<FormBuilderState>();
  final String ingredientTile = "Add Ingredient";
  final String otherIngTile = "If ingredient is not in list";
  String ingredientSelected = "";
  Map<String, Map<String,String>> recipes = {
    "Jodhpuri Aloo": {"potato, brown skin, small": "500.0", "chillies, red": "5.0", "cumin seeds": "4.2", "asafoetida": "1.05", "turmeric powder": "2.1", "coriander leaves": "8.4"},
    "Aloo Tomato vegetable": {"potato, brown skin, big": "83.33", "tomato, ripe, local": "66.67", "onion, big": "33.33", "cumin seeds": "0.714", "turmeric powder": "0.336", "coriander leaves": "1.386", "peas, fresh": "62.5"},
    "Tea": {"milk, whole, cow": "250.0"},
    "Daal": {"green gram, dal": "62.50", "onion, big": "32.5", "tomato, ripe, local": "62.5", "cumin seeds": "1.05", "ginger, fresh": "2.1", "turmeric powder": "0.252", "asafoetida": "0.252"},
    "Rice": {"rice, raw, milled": "60"},
    "Rice with Rajma": {"rice, raw, milled": "60", "rajmah, red": "62.5", "onion, big": "62.5", "tomato, ripe, local": "95.0", "coriander leaves": "1.596", "cumin seeds": "0.798", "turmeric powder": "0.252"}
  };
  List<DropMenuItem> measure = [
    DropMenuItem('Cup','assests/Cup.png'),
    DropMenuItem('Glass', 'assests/Glass.png'),
    DropMenuItem('Teaspoon', 'assests/Teaspoon.png'),
    DropMenuItem('Tablespoon', 'assests/Tablespoon.png'),
    DropMenuItem('Bowl', 'assests/Bowl.png'),
    DropMenuItem('Number', 'assests/Number.png'),
    DropMenuItem('Gram', 'assests/Gram.png'),
  ];

  Map<String, double> measureQty = {"Cup": 250, "Glass": 200, "Teaspoon": 4.2, "Tablespoon": 15, "Bowl": 180};

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("IITJ Diet"),
        centerTitle: true,
        backgroundColor: Colors.blue, // Colors.red[300],
          actions: [
            IconButton(
                onPressed: (){
                  //_formKey.currentState!.save();
                  Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => Tutorial())
                  );
                },
                icon: const Icon(
                    Icons.info_outline_rounded
                )
            )
          ]
      ),
      body: FormBuilder(
          key: _formKey1,
          // child: Padding(
          // padding:  const EdgeInsets.fromLTRB(8.0, 16.0, 8.0, 8.0),
    child:
    ListView(
        children: <Widget>[
          Text(
              "   Enter ingredient details for $itmName",
              // textAlign: TextAlign.left,
              // style: const TextStyle(
              //     color: Colors.white,
              //     fontSize: 16,
              //     fontWeight: FontWeight.bold
              // )
          ),
          const Divider(
            thickness: 5,
            height: 15,
            indent: 2,
            endIndent: 0,
            color: Colors.white30,
          ),
          Card(

              elevation: 50,
              shadowColor: Colors.black,
              color: Colors.white,
              child: ExpansionTile(

                title: Text(
                  ingredientTile,
                  style: const TextStyle(
                      color:Colors.black,
                      fontSize: 16.0,
                      fontWeight: FontWeight.w500),
                ),
                tilePadding: const EdgeInsets.all(10),
                maintainState: true,
                children: <Widget>[
                  Container(
                    width: 300,
                  child:
                  Column(
                      children:<Widget>[
                        DropdownSearch<String>(
                    popupProps: const PopupProps.menu(
                      showSearchBox: true,
                      showSelectedItems: true,
                    ),
                    items: ingredients,
                    dropdownDecoratorProps: const DropDownDecoratorProps(
                      dropdownSearchDecoration: InputDecoration(
                          labelText: "  IngredientList",
                          labelStyle: TextStyle(color: Colors.black),

                          //hintText: " Ingredients"
                      ),
                    ),
                    onChanged: (val){
                      ingredientSelected = val.toString();
                      print(ingredientSelected);
                    },
                  ),
                  ExpansionTile(
                    title: Text(otherIngTile),
                    maintainState: true,
                    backgroundColor: Colors.white,
                    collapsedBackgroundColor: Colors.cyanAccent,
                    children: <Widget>[
                      const Text(
                        "Add the ingredient used",
                        style: TextStyle(color: Colors.blue),
                      ),
                      FormBuilderTextField(
                        name: "othering",
                      )
                    ],
                  )])),
                  Container(
                    width: 300,
                  padding: const EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 0.0) ,
                  child:
                  Column(
                    children:<Widget>[
                    FormBuilderDropdown<String>(
                    name: 'measureIng',
                    menuMaxHeight: 350,
                    validator: FormBuilderValidators.required(errorText: "This field is required"),
                    decoration: InputDecoration(
                      alignLabelWithHint: true,
                      labelText: '   Select a measure',
                      suffix: IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () {
                          _formKey1.currentState!.fields['measureIng']
                              ?.reset();
                        },
                      ),
                      hintText: 'Select Measure',
                    ),
                    items: measure
                        .map((measureIng) => DropdownMenuItem(
                      alignment: AlignmentDirectional.bottomCenter,
                      value: measureIng.value,
                      child:Row(
                        children: [
                          Image.asset(
                              measureIng.image,
                            width: 40,
                            height: 40,
                          ),

                          Text(measureIng.value, style: const TextStyle(fontSize : 12),),
                        ],
                      ),

                    ))
                        .toList(),
                  ),
                    // IconButton(
                    //     onPressed: (){
                    //       //_formKey.currentState!.save();
                    //       Navigator.push(
                    //           context,
                    //           MaterialPageRoute(builder: (context) => const Tutorial())
                    //       );
                    //     },
                    //     icon: const Icon(
                    //         Icons.info_outline_rounded
                    //     )
                    // )]),
                  //const Text("\n Enter the quantity"),
                  FormBuilderTextField(
                    name: "ingquantity",
                    //initialValue: "    Enter the quantity",
                    decoration: const InputDecoration(
                      //labelText: 'Name',
                      border: InputBorder.none,
                      hintText: 'Enter the quantity',
                      filled: true,
                    ),
                    keyboardType: TextInputType.number,
                    validator: FormBuilderValidators.required(errorText: "This field is required"),
                  ),
                  ElevatedButton(
                    onPressed: (){
                      String drpItm = "";
                      String foodItm = "";
                      if(itmName != "" && itmName != "null"){
                        drpItm = itmName;
                      }
                      String othItm = "";
                      //othItm = recipeName;
                      if(drpItm != "null" && drpItm != ""){
                        foodItm = drpItm;
                      }
                      else if(othItm != "null" && othItm != ""){
                        foodItm = othItm;
                      }

                      //_formKey1.currentState!.save();
                      String ingredient = "";
                      if(ingredientSelected != "" && ingredientSelected != "null"){
                        ingredient = ingredientSelected;
                      }
                      print(_formKey1.currentState);
                      print(_formKey1.currentState!.fields['othering']);
                      var x = _formKey1.currentState!.fields['othering'];
                      print("4");
                      String otherIng = "";
                      if(x != null){
                        otherIng = _formKey1.currentState!.fields['othering']!.value.toString();
                      }
                      if((ingredientSelected == "null" || ingredientSelected == "") && (otherIng == "null" || otherIng == "")){
                        showDialog(
                            context: context,
                            builder: (ctx) => AlertDialog(
                              title: const Text("Incorrect Details Entered!"),
                              content: const Text("Enter name of the ingredient"),
                              actions: <Widget>[
                                ElevatedButton(
                                    onPressed: () {
                                      Navigator.of(ctx).pop();
                                    },
                                    child: const Text("Ok")
                                )
                              ],
                            )
                        );
                        return;
                      }
                      print('1');
                      bool chk1 = _formKey1.currentState!.fields['measureIng']!.validate() &&
                          _formKey1.currentState!.fields['ingquantity']!.validate();
                      print("2");
                      if(chk1){
                        if(ingredientSelected != "null" && ingredientSelected != ""){
                          ingredient = ingredientSelected;
                          print(ingredient);
                        }
                        else if(otherIng != "null" && otherIng != ""){
                          ingredient = otherIng;
                        }
                        print(itmName);
                        String ingMeasure = _formKey1.currentState!.fields['measureIng']!.value.toString();
                        String ingQuantity = _formKey1.currentState!.fields['ingquantity']!.value.toString();
                        globals.ingMap.putIfAbsent(ingredient, () => 0.0);
                        if(ingMeasure == "" || ingMeasure == "null" || ingQuantity == "" || ingQuantity == "null"){
                          if(recipes.containsKey(itmName)){
                            if(recipes[itmName]!.containsKey(ingredient)){
                              globals.ingMap[ingredient] = globals.ingMap[ingredient] !+ double.parse(recipes[itmName]![ingredient] ?? "0.0");
                            }
                          }
                          print(globals.ingMap);
                          return;
                        }
                        if(ingMeasure == "Gram"){
                          if(globals.ingMap[ingredient] != null){
                            globals.ingMap[ingredient] = globals.ingMap[ingredient] !+ double.parse(ingQuantity);
                          }
                        }
                        else{
                          double? qty = 0.0;
                          qty = measureQty[ingMeasure];
                          globals.ingMap[ingredient] = globals.ingMap[ingredient] !+ qty !* double.parse(ingQuantity);
                        }
                        print("IngMap: ");
                        print(globals.ingMap);
                        _formKey1.currentState!.fields['measureIng']!.reset();
                        _formKey1.currentState!.fields['ingquantity']!.reset();
                        _formKey1.currentState!.fields['othering']!.reset();
                        print("done");
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                          content: Text("Ingredient Submitted Successfully"),
                        ));
                      }
                      else{
                        return;
                      }
                    },
                    child: Text("Submit Ingredient"),
                  )
                ],
              ) ),
          ElevatedButton(
              onPressed: (){
                Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => FoodQuantity(dateRecall: dateRecall, ingredients: ingredients, namePatient: namePatient, itmName: itmName))
                );
              },
              child: const Text("Enter Food Quantity Details")
          ),
        ]

      )),
      ])
          ));

  }
}

class FoodQuantity extends StatelessWidget {
  FoodQuantity({Key? key, required this.dateRecall, required this.ingredients, required this.namePatient, required this.itmName}) : super(key: key);
  final String dateRecall;
  final List<String>ingredients;
  final String namePatient;
  final String itmName;
  final String foodPrepared = "Prepared food details";
  final String foodConsumed = "Consumed food details";

  Map<String, double> measureQty = {"Cup": 250, "Glass": 200, "Teaspoon": 4.2, "Tablespoon": 15, "Bowl": 180};
  Map<String, dynamic> mp = {};
  final List<String> nutrient=[];
  final List<double> value=[];
  final _formKey = GlobalKey<FormBuilderState>();
  List<DropMenuItem> measure = [
    DropMenuItem('Cup','assests/Cup.png'),
    DropMenuItem('Glass', 'assests/Glass.png'),
    DropMenuItem('Teaspoon', 'assests/Teaspoon.png'),
    DropMenuItem('Tablespoon', 'assests/Tablespoon.png'),
    DropMenuItem('Bowl', 'assests/Bowl.png'),
    DropMenuItem('Number', 'assests/Number.png'),
    DropMenuItem('Gram', 'assests/Gram.png'),
  ];
  Future<void> Temp(String nm, String qty) async {
    var headers = {
      'Content-Type': 'text/plain'
    };
    var request = http.Request('GET', Uri.parse('http://harsh1111.pythonanywhere.com/ALL/'));
    request.body = '''{\r\n\t"name" : "$nm",\r\n\t"quantitiy" : "$qty"\r\n}''';
    request.headers.addAll(headers);
    http.StreamedResponse response = await request.send();
    print(response.statusCode);
    var x;
    if (response.statusCode == 200) {
      final resp = await response.stream.bytesToString();
      var x = json.decode(resp) as Map<String, dynamic>;

      x.forEach((nutrients, values) {
        mp.putIfAbsent(nutrients, () => 0.0);
        mp[nutrients] = mp[nutrients] !+ values;
        nutrient.add(nutrients);
        value.add(values);
      });
      print(mp);
    }
    else {
      print(response.reasonPhrase);
    }
  }

  void writeDataNutrientInfo(String pId, String date) async {

    var url = "https://foodapp-5369f-default-rtdb.firebaseio.com/NutrientInfo.json";

    // (Do not remove “data.json”,keep it as it is)
    try {
      print("mp:");
      print(mp);
      mp["PatientId"] = pId;
      mp["date"] = date;
      print(mp);
      final response = await http.post(
        Uri.parse(url),
        body: json.encode(
            mp
        ),
      );
    } catch (error) {
      throw error;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("IITJ Diet"),
        centerTitle: true,
        backgroundColor: Colors.blue[300],
          actions: [
            IconButton(
                onPressed: (){
                  _formKey.currentState!.save();
                  Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => Tutorial())
                  );
                },
                icon: const Icon(
                    Icons.info_outline_rounded
                )
            )
          ]
      ),
      body: FormBuilder(
        key: _formKey,
        child: ListView(
          children: <Widget>[
            Text("\n\n   Enter the quantity details for $itmName \n \n"),
            ExpansionTile(
              title: Text(
                foodPrepared,
              ),
              tilePadding: EdgeInsets.all(10),
              backgroundColor: Colors.white,
              collapsedBackgroundColor: Colors.blue,
              maintainState: true,

              children: <Widget>[
                Container(
                  width: 300,
                child: Column(
                  children: <Widget>[FormBuilderDropdown<String>(
                    menuMaxHeight: 500,
                  name: 'measureprep',
                  validator: FormBuilderValidators.required(errorText: "This field is required"),
                  //initialValue: 'Breakfast',
                  decoration: InputDecoration(
                    labelText: '  Select a measure',
                    alignLabelWithHint: true,
                    suffix: IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () {
                        _formKey.currentState!.fields['measureprep']
                            ?.reset();
                      },
                    ),
                    hintText: 'Select Measure',
                  ),
                  items: measure
                      .map((measureIng) => DropdownMenuItem(
                    alignment: AlignmentDirectional.bottomCenter,
                    value: measureIng.value,
                    child:Row(
                      children: [
                        Image.asset(
                          measureIng.image,
                          width: 40,
                          height: 40,
                        ),

                        Text(measureIng.value, style: const TextStyle(fontSize : 12),),
                      ],
                    ),

                  ))
                      .toList(),
                ),
                //const Text("\n Enter the quantity"),
                FormBuilderTextField(
                    name: "preparequan",
                    decoration: const InputDecoration(
                      //labelText: 'Name',
                      border: InputBorder.none,
                      hintText: 'Enter the quantity',
                      filled: true,
                    ),
                    validator: FormBuilderValidators.required(errorText: "This field is required"),
                    keyboardType: TextInputType.number
                ),
              ],
            ))]),
            const Divider(
              thickness: 5,
              height: 15,
              indent: 2,
              endIndent: 0,
              color: Colors.white30,
            ),
            ExpansionTile(

              title: Text(
                foodConsumed,
              ),
              tilePadding: EdgeInsets.all(10),
              backgroundColor: Colors.white,
              collapsedBackgroundColor: Colors.blue,
              maintainState: true,

              children: <Widget>[
                Container(
                    width:300,
                    child: Column( children: <Widget>[
                FormBuilderDropdown<String>(
                  menuMaxHeight: 500,
                  name: 'measurecon',
                  validator: FormBuilderValidators.required(errorText: "This field is required"),
                  decoration: InputDecoration(
                    labelText: '  Select a measure',
                    alignLabelWithHint: true,
                    suffix: IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () {
                        _formKey.currentState!.fields['measurecon']
                            ?.reset();
                      },
                    ),
                    hintText: 'Select Measure',
                  ),
                  items: measure
                      .map((measureIng) => DropdownMenuItem(
                    alignment: AlignmentDirectional.bottomCenter,
                    value: measureIng.value,
                    child:Row(
                      children: [
                        Image.asset(
                          measureIng.image,
                          width: 40,
                          height: 40,
                        ),

                        Text(measureIng.value, style: const TextStyle(fontSize : 12),),
                      ],
                    ),

                  ))
                      .toList(),
                ),
                //const Text(
                   // "\n\n Enter the quantity",
                  //textAlign: TextAlign.start,
                //),
                FormBuilderTextField(
                    name: "consumequan",
                    decoration: const InputDecoration(
                      //labelText: 'Name',
                      border: InputBorder.none,
                      hintText: 'Enter the quantity',
                      filled: true,
                    ),
                    validator: FormBuilderValidators.required(errorText: "This field is required"),
                    keyboardType: TextInputType.number
                ),
              ],
            ))]),
            ElevatedButton(
                style: ElevatedButton.styleFrom(
                  primary: Colors.purple,
                  padding: EdgeInsets.symmetric(horizontal: 0, vertical: 10),
                  // Style: TextStyle( fontSize: 18, fontWeight: FontWeight.normal)
                ),
                onPressed: (){
                  String pName = namePatient;
                  DateTime now = DateTime.now();
                  final DateFormat formatter = DateFormat('yyyy-MM-dd');
                  String formatted = formatter.format(now);
                  String date = formatted;
                  String drpItm = "";
                  bool chk = true;
                  if(chk){
                    String itmName;
                    int flag = 0;
                    String fdprepMeasure = _formKey.currentState!.fields['measureprep']!.value.toString();
                    String fdprepQuantity = _formKey.currentState!.fields['preparequan']!.value.toString();
                    String fdconMeasure = _formKey.currentState!.fields['measurecon']!.value.toString();
                    String fdconQuantity = _formKey.currentState!.fields['consumequan']!.value.toString();
                    double? ratio = 0.0;
                    double? num = 0.0;
                    double? deno = 0.0;
                    if(fdprepMeasure == "Gram"){
                      deno = double.parse(fdprepQuantity);
                    }
                    else{
                      deno = measureQty[fdprepMeasure]! * double.parse(fdprepQuantity);
                    }
                    if(fdconMeasure == "Gram"){
                      num = double.parse(fdconQuantity);
                    }
                    else{
                      num = measureQty[fdconMeasure]! * double.parse(fdconQuantity);

                    }
                    ratio = num/deno;
                    globals.ingMap.forEach((key, value) {
                      globals.ingMap[key] = value * ratio!;
                      globals.ingMap[key] = globals.ingMap[key]!/100;
                    });
                    print("INGMAP: ");
                    print(globals.ingMap);
                    if(_formKey.currentState!.fields['measureprep'] != null){
                      _formKey.currentState!.fields['measureprep']!.reset();
                    }
                    if(_formKey.currentState!.fields['preparequan'] != null){
                      _formKey.currentState!.fields['preparequan']!.reset();
                    }
                    if(_formKey.currentState!.fields['measurecon'] != null){
                      _formKey.currentState!.fields['measurecon']!.reset();
                    }
                    if(_formKey.currentState!.fields['consumequan'] != null){
                      _formKey.currentState!.fields['consumequan']!.reset();
                    }
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                      content: Text("Food Item Submitted Successfully"),
                    ));
                    int count = 0;
                    Navigator.of(context).popUntil((_) => count++ >= 2);
                  }
                  else{
                    return;
                  }
                },
                child: const Text("Submit Food Item And Add Another")
            ),
            /*ElevatedButton(
                style: ElevatedButton.styleFrom(
                  primary: Colors.purple,
                  padding: EdgeInsets.symmetric(horizontal: 0, vertical: 10),
                  // Style: TextStyle( fontSize: 18, fontWeight: FontWeight.normal)
                ),
                onPressed: (){
                  String pName = namePatient;
                  DateTime now = DateTime.now();
                  final DateFormat formatter = DateFormat('yyyy-MM-dd');
                  String formatted = formatter.format(now);
                  String date = formatted;
                  String drpItm = "";
                  bool chk = true;
                  if(chk){
                    String itmName;
                    int flag = 0;
                    String fdprepMeasure = _formKey.currentState!.fields['measureprep']!.value.toString();
                    String fdprepQuantity = _formKey.currentState!.fields['preparequan']!.value.toString();
                    String fdconMeasure = _formKey.currentState!.fields['measurecon']!.value.toString();
                    String fdconQuantity = _formKey.currentState!.fields['consumequan']!.value.toString();
                    double? ratio = 0.0;
                    double? num = 0.0;
                    double? deno = 0.0;
                    if(fdprepMeasure == "Gram"){
                      deno = double.parse(fdprepQuantity);
                    }
                    else{
                      deno = measureQty[fdprepMeasure]! * double.parse(fdprepQuantity);
                    }
                    if(fdconMeasure == "Gram"){
                      num = double.parse(fdconQuantity);
                    }
                    else{
                      num = measureQty[fdconMeasure]! * double.parse(fdconQuantity);

                    }
                    ratio = num/deno;
                    globals.ingMap.forEach((key, value) {
                      globals.ingMap[key] = value * ratio!;
                      globals.ingMap[key] = globals.ingMap[key]!/100;
                    });
                    print("INGMAP: ");
                    print(globals.ingMap);
                    if(_formKey.currentState!.fields['measureprep'] != null){
                      _formKey.currentState!.fields['measureprep']!.reset();
                    }
                    if(_formKey.currentState!.fields['preparequan'] != null){
                      _formKey.currentState!.fields['preparequan']!.reset();
                    }
                    if(_formKey.currentState!.fields['measurecon'] != null){
                      _formKey.currentState!.fields['measurecon']!.reset();
                    }
                    if(_formKey.currentState!.fields['consumequan'] != null){
                      _formKey.currentState!.fields['consumequan']!.reset();
                    }
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                      content: Text("Food Item Submitted Successfully"),
                    ));
                  }
                  else{
                    return;
                  }
                },
                child: const Text("Submit Food Item")
            ),*/
            ElevatedButton(
                onPressed: (){
                  int count = 0;
                  String pName = namePatient;
                  DateTime now = DateTime.now();
                  final DateFormat formatter = DateFormat('yyyy-MM-dd');
                  String formatted = formatter.format(now);
                  String date = formatted;
                  List<Future<void>> allItms = [];
                  String drpItm = "";
                  bool chk = true;
                  if(chk){
                    String itmName;
                    int flag = 0;
                    String fdprepMeasure = _formKey.currentState!.fields['measureprep']!.value.toString();
                    String fdprepQuantity = _formKey.currentState!.fields['preparequan']!.value.toString();
                    String fdconMeasure = _formKey.currentState!.fields['measurecon']!.value.toString();
                    String fdconQuantity = _formKey.currentState!.fields['consumequan']!.value.toString();
                    double? ratio = 0.0;
                    double? num = 0.0;
                    double? deno = 0.0;
                    if(fdprepMeasure == "Gram"){
                      deno = double.parse(fdprepQuantity);
                    }
                    else{
                      deno = measureQty[fdprepMeasure]! * double.parse(fdprepQuantity);
                    }
                    if(fdconMeasure == "Gram"){
                      num = double.parse(fdconQuantity);
                    }
                    else{
                      num = measureQty[fdconMeasure]! * double.parse(fdconQuantity);

                    }
                    ratio = num/deno;
                    globals.ingMap.forEach((key, value) {
                      globals.ingMap[key] = value * ratio!;
                      globals.ingMap[key] = globals.ingMap[key]!/100;
                    });
                    print("INGMAP: ");
                    print(globals.ingMap);
                    if(_formKey.currentState!.fields['measureprep'] != null){
                      _formKey.currentState!.fields['measureprep']!.reset();
                    }
                    if(_formKey.currentState!.fields['preparequan'] != null){
                      _formKey.currentState!.fields['preparequan']!.reset();
                    }
                    if(_formKey.currentState!.fields['measurecon'] != null){
                      _formKey.currentState!.fields['measurecon']!.reset();
                    }
                    if(_formKey.currentState!.fields['consumequan'] != null){
                      _formKey.currentState!.fields['consumequan']!.reset();
                    }
                  }
                  globals.ingMap.forEach((key, value) {
                    allItms.add(Temp(key, value.toString()));
                  });
                  Future.wait(allItms).then((value)=>{
                    globals.ingMap.clear(),
                    writeDataNutrientInfo(pName, date),
                    Navigator.of(context).popUntil((_) => count++ >= 4)

                  });

                },
                child: const Text("Submit and close form")
            )
          ]
        )
      )
    );
  }
}



class DRForm extends StatelessWidget {
  DRForm({Key? key, required this.dateRecall, required this.cheatMeal, required this.foodItems, required this.ingredients, required this.namePatient}) : super(key: key);
  final List<String> nutrient=[];
  final List<double> value=[];
  Map<String, dynamic> mp = {};
  List<Future<void>> allItms = [];
  Future<void> Temp(String nm, String qty) async {
    var headers = {
      'Content-Type': 'text/plain'
    };
    var request = http.Request('GET', Uri.parse('http://harsh1111.pythonanywhere.com/ALL/'));
    request.body = '''{\r\n\t"name" : "$nm",\r\n\t"quantitiy" : "$qty"\r\n}''';
    request.headers.addAll(headers);
    http.StreamedResponse response = await request.send();
    print(response.statusCode);
    var x;
    if (response.statusCode == 200) {
      final resp = await response.stream.bytesToString();
      var x = json.decode(resp) as Map<String, dynamic>;

      x.forEach((nutrients, values) {
        mp.putIfAbsent(nutrients, () => 0.0);
        mp[nutrients] = mp[nutrients] !+ values;
        nutrient.add(nutrients);
        value.add(values);
      });
      print(mp);
    }
    else {
      print(response.reasonPhrase);
    }
  }

  void writeDataNutrientInfo(String pId, String date) async {

    var url = "https://foodapp-5369f-default-rtdb.firebaseio.com/NutrientInfo.json";

    // (Do not remove “data.json”,keep it as it is)
    try {
      print("mp:");
      print(mp);
      mp["PatientId"] = pId;
      mp["date"] = date;
      print(mp);
      final response = await http.post(
        Uri.parse(url),
        body: json.encode(
            mp
        ),
      );
    } catch (error) {
      throw error;
    }
  }

  final String dateRecall;
  final bool cheatMeal;
  final namePatient;
  //print(namePatient);
  final List<String> foodItems;
  final List<String>ingredients;
  final _formKey = GlobalKey<FormBuilderState>();
  final fdIng = <String, List<String>>{};
  final fdQty = <String, List<String>>{};
  final IngInfo = <List<String>>[];
  List<String> mealName = ['Breakfast', 'Between breakfast and lunch', 'Lunch', 'Between lunch and dinner', 'Dinner', 'After Dinner'];
  List<String> measure = ['Cup', 'Glass', 'Teaspoon', 'Tablespoon', 'Bowl', 'Number', 'Gram'];
  final firstexpansion="Select meal time";
  final secondexpansion= "Enter Patient detail";
  final thirdexpansion= "Enter Food Item";
  final otherTile = "If food item is not in list";
  final otherIngTile = "If ingredient is not in list";
  final ingredientTile = "Add Ingredient";
  final foodTile = "Add Ingredient";
  final foodPrepared = "Prepared food details";
  final foodConsumed = "Consumed food details";
  Map<String, double> measureQty = {"Cup": 250, "Glass": 200, "Teaspoon": 4.2, "Tablespoon": 15, "Bowl": 180};
  Map<String, double> ingMap = {};
  Map<String, double> recipeMap = {};
  String foodItemSelected = "";
  String ingredientSelected = "";
  List<String> recipeFoods = ["Jodhpuri Aloo", "Aloo Tomato vegetable", "Tea"];
  String recipeName = "";
  //Map<String,String> jAlooRecipe = {"potato, brown skin, small": "500.0", "chillies, red": "5.0", "cumin seeds": "4.2", "asafoetida": "1.05", "turmeric powder": "2.1", "coriander leaves": "8.4"};
  Map<String, Map<String,String>> recipes = {"Jodhpuri Aloo": {"potato, brown skin, small": "500.0", "chillies, red": "5.0", "cumin seeds": "4.2", "asafoetida": "1.05", "turmeric powder": "2.1", "coriander leaves": "8.4"},
    "Aloo Tomato vegetable": {"potato, brown skin, big": "83.33", "tomato, ripe, local": "66.67", "onion, big": "33.33", "cumin seeds": "0.714", "turmeric powder": "0.336", "coriander leaves": "1.386", "peas, fresh": "62.5"},
    "Tea": {"milk, whole, cow": "250.0"},
    "Daal": {"green gram, dal": "62.50", "onion, big": "32.5", "tomato, ripe, local": "62.5", "cumin seeds": "1.05", "ginger, fresh": "2.1", "turmeric powder": "0.252", "asafoetida": "0.252"},
    "Rice": {"rice, raw, milled": "60"},
    "Rice with Rajma": {"rice, raw, milled": "60", "rajmah, red": "62.5", "onion, big": "62.5", "tomato, ripe, local": "95.0", "coriander leaves": "1.596", "cumin seeds": "0.798", "turmeric powder": "0.252"}};
  //String namePatient = "";
  bool recipeInpIng = true;
  @override
  Widget build(BuildContext context){
    //print(foodItems);
    return Scaffold(
      appBar: AppBar(
          title: const Text("IITJ Diet"),
          centerTitle: true,
          backgroundColor: (cheatMeal) ? Colors.blue[800] : Colors.red[300],
          actions: [
            IconButton(
                onPressed: (){
                  _formKey.currentState!.save();
                  Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) =>  Tutorial())
                  );
                },
                icon: const Icon(
                    Icons.info_outline_rounded
                )
            )
          ]
      ),
      body: FormBuilder(
        key: _formKey,
        child: ListView(
            padding: const EdgeInsets.all(20),
            children: <Widget>[
              Card(
                //const Text("")
                elevation: 50,
                shadowColor: Colors.black,
                color: Colors.blueAccent,
                shape:  const RoundedRectangleBorder(
                  side: BorderSide(
                    color: Colors.blueAccent,
                    width: 3.0,
                  ),),
                child: Card(
                        elevation: 100,
                        shadowColor: Colors.black,
                        color: Colors.blueAccent,



                        child: FormBuilderDropdown<String>(
                          name: 'mealType',
                          dropdownColor: Colors.black45,
                          borderRadius: const BorderRadius.all(
                              Radius.circular(20)),
                          menuMaxHeight: 200,
                          //style: TextStyle(color: Colors.black45, fontSize: 20.0),
                          itemHeight: 50,
                          validator: FormBuilderValidators.required(errorText: "This field is required"),
                          //initialValue: 'Breakfast',
                          decoration: InputDecoration(
                            labelText: '   Select a meal',
                            alignLabelWithHint: true,
                            labelStyle: const TextStyle(
                                color: Colors.white
                            ),
                            suffix: IconButton(
                              icon: const Icon(Icons.close),
                              onPressed: () {
                                _formKey.currentState!.fields['mealType']
                                    ?.reset();
                              },
                            ),
                            hintText: 'Select Meal',
                          ),
                          items: mealName
                              .map((mealType) => DropdownMenuItem(
                            alignment: AlignmentDirectional.center,
                            value: mealType,

                            child: Align(
                                alignment: Alignment.centerLeft,
                                child: Text(
                                  mealType,

                                  style: TextStyle( color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                                )),
                          ))
                              .toList(),
                        ),



                      ),



              ),
              const Divider(
                thickness: 5,
                height: 15,
                indent: 2,
                endIndent: 0,
                color: Colors.white30,
              ),
              Card(
                elevation: 50,
                shadowColor: Colors.black,
                color: Colors.blueAccent,
                shape:  const RoundedRectangleBorder(
                  side: BorderSide(
                    color: Colors.blueAccent,
                    width: 3.0,
                  ),),
                child: ExpansionTile(

                  maintainState: true,
                  title: Text(
                    thirdexpansion,
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16.0,
                        fontWeight: FontWeight.w500),
                    //style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.w500),
                  ),
                  tilePadding: EdgeInsets.all(10),

                  children: <Widget>[

                    DropdownSearch<String>(
                      popupProps: const PopupProps.menu(
                        showSearchBox: true,
                        showSelectedItems: true,
                      ),
                      items: foodItems,
                      dropdownDecoratorProps: const DropDownDecoratorProps(
                        dropdownSearchDecoration: InputDecoration(
                          labelText: "    FoodItemList",
                          labelStyle: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                          ),
                          hintText: "Food Items",
                        ),
                      ),
                      onChanged: (val){
                        foodItemSelected = val.toString();
                        print(foodItemSelected);
                      },
                    ),

                    ExpansionTile(
                        title: Text(
                          otherTile,
                          style: TextStyle(color: Colors.white),
                        ),
                        maintainState: true,
                        children: <Widget>[
                          const Text(
                            "Enter the food you consumed",
                            textAlign: TextAlign.start,
                            style: TextStyle(color: Colors.white),

                          ),
                          /*FormBuilderTextField(
                              initialValue: "Erase and Write here",
                                name: "otherFoodItem",
                                    //autocorrect: true,
                                    autofocus: false,
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(color: Colors.white, fontSize:12, fontStyle: FontStyle.italic ),
                            )*/
                          DropdownSearch<String>(
                            popupProps: const PopupProps.menu(
                              showSearchBox: true,
                              showSelectedItems: true,
                            ),
                            items: recipeFoods,
                            dropdownDecoratorProps: const DropDownDecoratorProps(
                              dropdownSearchDecoration: InputDecoration(
                                labelText: "    FoodItemList",
                                labelStyle: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                ),
                                hintText: "recipeFoods",
                              ),
                            ),
                            onChanged: (val){
                              recipeName = val.toString();
                              print(recipeName);
                            },
                          ),
                        ]
                    ),
                  ],
                ),
              ),



              const Divider(
                thickness: 5,
                height: 15,
                indent: 2,
                endIndent: 0,
                color: Colors.white30,
              ),
              Card(

                  elevation: 50,
                  shadowColor: Colors.black,
                  color: Colors.white,
                  child: ExpansionTile(

                    title: Text(

                      ingredientTile,

                      style: const TextStyle(
                          color:Colors.white,
                          fontSize: 16.0,
                          fontWeight: FontWeight.w500
                      ),
                    ),
                    tilePadding: EdgeInsets.all(10),
                    maintainState: true,
                    children: <Widget>[
                      DropdownSearch<String>(
                        popupProps: const PopupProps.menu(
                          showSearchBox: true,
                          showSelectedItems: true,
                        ),
                        items: ingredients,
                        dropdownDecoratorProps: const DropDownDecoratorProps(
                          dropdownSearchDecoration: InputDecoration(
                              labelText: "IngredientList",
                              labelStyle: TextStyle(color: Colors.white),
                              hintText: "Ingredients"
                          ),
                        ),
                        onChanged: (val){
                          ingredientSelected = val.toString();
                          print(ingredientSelected);
                        },
                      ),
                      ExpansionTile(
                        title: Text(otherIngTile),
                        maintainState: true,
                        backgroundColor: Colors.white,
                        collapsedBackgroundColor: Colors.cyanAccent,
                        children: <Widget>[
                          const Text(
                            "Add the ingredient used",
                            style: TextStyle(color: Colors.blue),
                          ),
                          FormBuilderTextField(
                            name: "othering",
                          )
                        ],
                      ),
                      FormBuilderDropdown<String>(
                        name: 'measureIng',
                        validator: FormBuilderValidators.required(errorText: "This field is required"),
                        decoration: InputDecoration(
                          labelText: 'Select a measure',
                          alignLabelWithHint: true,
                          suffix: IconButton(
                            icon: const Icon(Icons.close),
                            onPressed: () {
                              _formKey.currentState!.fields['measureIng']
                                  ?.reset();
                            },
                          ),
                          hintText: 'Select Measure',
                        ),
                        items: measure
                            .map((measureIng) => DropdownMenuItem(
                          alignment: AlignmentDirectional.center,
                          value: measureIng,
                          child: Text(measureIng),
                        ))
                            .toList(),
                      ),
                      const Text("Enter the quantity"),
                      FormBuilderTextField(
                        name: "ingquantity",
                        keyboardType: TextInputType.number,
                        validator: FormBuilderValidators.required(errorText: "This field is required"),
                      ),
                      ElevatedButton(
                        onPressed: (){
                          String drpItm = "";
                          String itmName = "";
                          if(foodItemSelected != "" && foodItemSelected != "null"){
                            drpItm = foodItemSelected;
                          }
                          String othItm = "";
                          othItm = recipeName;
                          if(drpItm != "null" && drpItm != ""){
                            itmName = drpItm;
                          }
                          else if(othItm != "null" && othItm != ""){
                            itmName = othItm;
                          }
                          _formKey.currentState!.save();
                          String ingredient = "";
                          if(ingredientSelected != "" && ingredientSelected != "null"){
                            ingredient = ingredientSelected;
                          }
                          var x = _formKey.currentState!.fields['othering'];
                          String otherIng = "";
                          if(x != null){
                            otherIng = _formKey.currentState!.fields['othering']!.value.toString();
                          }
                          if((ingredientSelected == "null" || ingredientSelected == "") && (otherIng == "null" || otherIng == "")){
                            showDialog(
                                context: context,
                                builder: (ctx) => AlertDialog(
                                  title: const Text("Incorrect Details Entered!"),
                                  content: const Text("Enter name of the ingredient"),
                                  actions: <Widget>[
                                    ElevatedButton(
                                        onPressed: () {
                                          Navigator.of(ctx).pop();
                                        },
                                        child: const Text("Ok")
                                    )
                                  ],
                                )
                            );
                            return;
                          }
                          bool chk1 = _formKey.currentState!.fields['measureIng']!.validate() &&
                              _formKey.currentState!.fields['ingquantity']!.validate();

                          if(chk1){
                            if(ingredientSelected != "null" && ingredientSelected != ""){
                              ingredient = ingredientSelected;
                              print(ingredient);
                            }
                            else if(otherIng != "null" && otherIng != ""){
                              ingredient = otherIng;
                            }
                            String ingMeasure = _formKey.currentState!.fields['measureIng']!.value.toString();
                            String ingQuantity = _formKey.currentState!.fields['ingquantity']!.value.toString();
                            ingMap.putIfAbsent(ingredient, () => 0.0);
                            if(ingMeasure == "" || ingMeasure == "null" || ingQuantity == "" || ingQuantity == "null"){
                              if(recipes.containsKey(itmName)){
                                if(recipes[itmName]!.containsKey(ingredient)){
                                  ingMap[ingredient] = ingMap[ingredient] !+ double.parse(recipes[itmName]![ingredient] ?? "0.0");
                                }
                              }
                              print(ingMap);
                              return;
                            }
                            if(ingMeasure == "Gram"){
                              if(ingMap[ingredient] != null){
                                ingMap[ingredient] = ingMap[ingredient] !+ double.parse(ingQuantity);
                              }
                            }
                            else{
                              double? qty = 0.0;
                              qty = measureQty[ingMeasure];
                              ingMap[ingredient] = ingMap[ingredient] !+ qty !* double.parse(ingQuantity);
                            }
                            _formKey.currentState!.fields['measureIng']!.reset();
                            _formKey.currentState!.fields['ingquantity']!.reset();
                            _formKey.currentState!.fields['othering']!.reset();
                            print("done");
                            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                              content: Text("Ingredient Submitted Successfully"),
                            ));
                          }
                          else{
                            return;
                          }
                        },
                        child: Text("Submit Ingredient"),
                      )
                    ],
                  ) ),
              const Divider(
                thickness: 5,
                height: 15,
                indent: 2,
                endIndent: 0,
                color: Colors.white30,
              ),
              ExpansionTile(
                title: Text(
                  foodPrepared,
                ),
                tilePadding: EdgeInsets.all(10),
                backgroundColor: Colors.white,
                collapsedBackgroundColor: Colors.blue,
                maintainState: true,
                children: <Widget>[
                  FormBuilderDropdown<String>(
                    name: 'measureprep',
                    validator: FormBuilderValidators.required(errorText: "This field is required"),
                    //initialValue: 'Breakfast',
                    decoration: InputDecoration(
                      labelText: 'Select a measure',
                      alignLabelWithHint: true,
                      suffix: IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () {
                          _formKey.currentState!.fields['measureprep']
                              ?.reset();
                        },
                      ),
                      hintText: 'Select Measure',
                    ),
                    items: measure
                        .map((measureprep) => DropdownMenuItem(
                      alignment: AlignmentDirectional.center,
                      value: measureprep,
                      child: Text(measureprep),
                    ))
                        .toList(),
                  ),
                  const Text("Enter the quantity"),
                  FormBuilderTextField(
                      name: "preparequan",
                      validator: FormBuilderValidators.required(errorText: "This field is required"),
                      keyboardType: TextInputType.number
                  ),
                ],
              ),
              const Divider(
                thickness: 5,
                height: 15,
                indent: 2,
                endIndent: 0,
                color: Colors.white30,
              ),
              ExpansionTile(

                title: Text(
                  foodConsumed,
                ),
                tilePadding: EdgeInsets.all(10),
                backgroundColor: Colors.white,
                collapsedBackgroundColor: Colors.blue,
                maintainState: true,
                children: <Widget>[
                  FormBuilderDropdown<String>(
                    name: 'measurecon',
                    validator: FormBuilderValidators.required(errorText: "This field is required"),
                    decoration: InputDecoration(
                      labelText: 'Select a measure',
                      alignLabelWithHint: true,
                      suffix: IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () {
                          _formKey.currentState!.fields['measurecon']
                              ?.reset();
                        },
                      ),
                      hintText: 'Select Measure',
                    ),
                    items: measure
                        .map((measurecon) => DropdownMenuItem(
                      alignment: AlignmentDirectional.center,
                      value: measurecon,
                      child: Text(measurecon),
                    ))
                        .toList(),
                  ),
                  const Text("Enter the quantity"),
                  FormBuilderTextField(
                      name: "consumequan",
                      validator: FormBuilderValidators.required(errorText: "This field is required"),
                      keyboardType: TextInputType.number
                  ),
                ],
              ),
              const Divider(
                thickness: 5,
                height: 15,
                indent: 2,
                endIndent: 0,
                color: Colors.white30,
              ),
              const Divider(
                thickness: 5,
                height: 15,
                indent: 2,
                endIndent: 0,
                color: Colors.white30,
              ),
              ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    primary: Colors.purple,
                    padding: EdgeInsets.symmetric(horizontal: 0, vertical: 10),
                    // Style: TextStyle( fontSize: 18, fontWeight: FontWeight.normal)
                  ),
                  onPressed: (){
                    String pName = namePatient;
                    DateTime now = DateTime.now();
                    final DateFormat formatter = DateFormat('yyyy-MM-dd');
                    String formatted = formatter.format(now);
                    String date = formatted;
                    String drpItm = "";
                    if(foodItemSelected != "" && foodItemSelected != "null"){
                      drpItm = foodItemSelected;
                    }
                    String othItm = "";
                    othItm = recipeName;
                    /*if(_formKey.currentState!.fields['otherFoodItem'] != null){
                          othItm = _formKey.currentState!.fields['otherFoodItem']!.value.toString();
                        }*/
                    if((drpItm == "null" || drpItm == "") && (othItm == "null" || othItm == "")){
                      showDialog(
                          context: context,
                          builder: (ctx) => AlertDialog(
                            title: const Text("Incorrect Details Entered!"),
                            content: const Text("Enter name of the food item"),
                            actions: <Widget>[
                              ElevatedButton(
                                  onPressed: () {
                                    Navigator.of(ctx).pop();
                                  },
                                  child: const Text("Ok")
                              )
                            ],
                          )
                      );
                      return;
                    }
                    //print(_formKey.currentState!.fields['mealType']);
                    //bool chk = _formKey.currentState!.fields['mealType']!.validate() && _formKey.currentState!.fields['patientName']!.validate() &&
                    //    _formKey.currentState!.fields['measureprep']!.validate() && _formKey.currentState!.fields['preparequan']!.validate() &&
                    //    _formKey.currentState!.fields['measurecon']!.validate() && _formKey.currentState!.fields['consumequan']!.validate();
                    bool chk = true;
                    if(chk){
                      String itmName;
                      int flag = 0;
                      String fdprepMeasure = _formKey.currentState!.fields['measureprep']!.value.toString();
                      String fdprepQuantity = _formKey.currentState!.fields['preparequan']!.value.toString();
                      String fdconMeasure = _formKey.currentState!.fields['measurecon']!.value.toString();
                      String fdconQuantity = _formKey.currentState!.fields['consumequan']!.value.toString();
                      if(drpItm != "null" && drpItm != ""){
                        itmName = drpItm;
                      }
                      else if(othItm != "null" && othItm != ""){
                        itmName = othItm;
                      }
                      if(recipeInpIng == false){

                      }
                      double? ratio = 0.0;
                      double? num = 0.0;
                      double? deno = 0.0;
                      if(fdprepMeasure == "Gram"){
                        deno = double.parse(fdprepQuantity);
                      }
                      else{
                        deno = measureQty[fdprepMeasure]! * double.parse(fdprepQuantity);
                      }
                      if(fdconMeasure == "Gram"){
                        num = double.parse(fdconQuantity);
                      }
                      else{
                        num = measureQty[fdconMeasure]! * double.parse(fdconQuantity);

                      }
                      ratio = num/deno;
                      ingMap.forEach((key, value) {
                        ingMap[key] = value * ratio!;
                        ingMap[key] = ingMap[key]!/100;
                      });
                      print("INGMAP: ");
                      print(ingMap);
                      if(_formKey.currentState!.fields['foodName'] != null){
                        _formKey.currentState!.fields['foodName']!.reset();
                      }
                      /*if(_formKey.currentState!.fields['otherFoodItem'] != null){
                            _formKey.currentState!.fields['otherFoodItem']!.reset();
                          }*/
                      if(_formKey.currentState!.fields['mealType'] != null){
                        _formKey.currentState!.fields['mealType']!.reset();
                      }
                      if(_formKey.currentState!.fields['measureprep'] != null){
                        _formKey.currentState!.fields['measureprep']!.reset();
                      }
                      if(_formKey.currentState!.fields['preparequan'] != null){
                        _formKey.currentState!.fields['preparequan']!.reset();
                      }
                      if(_formKey.currentState!.fields['measurecon'] != null){
                        _formKey.currentState!.fields['measurecon']!.reset();
                      }
                      if(_formKey.currentState!.fields['consumequan'] != null){
                        _formKey.currentState!.fields['consumequan']!.reset();
                      }



                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                        content: Text("Food Item Submitted Successfully"),
                      ));
                    }
                    else{
                      return;
                    }
                  },
                  child: const Text("Submit Food Item")
              ),
              ElevatedButton(
                  onPressed: (){
                    int count = 0;
                    String pName = namePatient;
                    DateTime now = DateTime.now();
                    final DateFormat formatter = DateFormat('yyyy-MM-dd');
                    String formatted = formatter.format(now);
                    String date = formatted;
                    ingMap.forEach((key, value) {
                      allItms.add(Temp(key, value.toString()));
                    });
                    Future.wait(allItms).then((value)=>{
                      writeDataNutrientInfo(pName, date),
                      Navigator.of(context).popUntil((_) => count++ >= 3)

                    });

                  },
                  child: const Text("Submit and close form")
              )
            ]
        ),
      ),
    );
  }

  stack({required List<Widget> children}) {}
}
const String _documentPath = 'assests/Flipbook/FilpBook New 03-01-2019_final.pdf';
class Tutorial extends StatefulWidget {
  //MyHomePage({Key key}) : super(key: key);

  @override
  _Tutorial createState() => _Tutorial();
}

class _Tutorial extends State<Tutorial> {
  //const Tutorial({Key? key}) : super(key: key);
  Future<String> prepareTestPdf() async {
    final ByteData bytes =
    await DefaultAssetBundle.of(context).load(_documentPath);
    final Uint8List list = bytes.buffer.asUint8List();

    final tempDir = await getTemporaryDirectory();
    final tempDocumentPath = '${tempDir.path}/$_documentPath';

    final file = await File(tempDocumentPath).create(recursive: true);
    file.writeAsBytesSync(list);
    return tempDocumentPath;
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("IITJ Diet"),
        centerTitle: true,
        backgroundColor: Colors.blue[300],
      ),
      body: Column(
        children:   <Widget>
        [
          const Text("\n\n   Guess your measurement by viewing these utensils"),
          const Text("\n इन बर्तनों को देखकर अपने माप का अनुमान लगाओ | \n "),

          ExpansionTile(
              title: Text(
                  "Bowl",
                  style: TextStyle(color: Colors.white)
              ),
              //tilePadding: const EdgeInsets.fromLTRB(8.0, 16.0, 8.0, 8.0),
              leading: CircleAvatar(
                  child: Image.asset('assests/Bowl.png', width:20, height:20)),
              backgroundColor: Colors.white,
              collapsedBackgroundColor: Colors.blueAccent,
              children:<Widget>[
                ListView(
                  scrollDirection: Axis.vertical,

                  shrinkWrap: true,// <-- Like so
                  //controller: _scrollController,
                  //physics: NeverScrollableScrollPhysics(),
                  children: <Widget>[
                    ExpansionTile(
                        title: Text("Common"),
                        children:<Widget>[
                          Container(
                            //width: 160.0,
                            //color: Colors.red,
                            child: Image.asset(
                                'assests/Bowl/Common.jpg', width:200,height:200 ),
                          )]),
                    ExpansionTile(
                        title: Text("1 Bowl"),
                        children:<Widget>[
                          Container(
                            //width: 160.0,
                            //color: Colors.red,
                            child: Image.asset('assests/Bowl/1.jpg',width:150,height:150 ),
                          )]),
                    ExpansionTile(
                        title: Text("Half Bowl"),
                        children:<Widget>[
                          Container(
                            //width: 160.0,
                            //color: Colors.red,
                              child: Image.asset('assests/Bowl/1-2.jpg', width:150,height:150)
                          )]),
                    ExpansionTile(
                        title: Text("One-third Bowl"),
                        children:<Widget>[
                          Container(
                            //width: 160.0,
                            //color: Colors.red,
                              child: Image.asset('assests/Bowl/1-3.jpg',width:150,height:150)
                          )]),
                    ExpansionTile(
                        title: Text("One-fourth Bowl"),
                        children:<Widget>[
                          Container(
                            //width: 160.0,
                            //color: Colors.red,
                              child: Image.asset('assests/Bowl/1-4.jpg',width:150,height:150)
                          )]),
                  ],
                )
              ]
          ),
          const SizedBox(
            //Use of SizedBox
            height: 6,
          ),
          ExpansionTile(
              title: Text(
                "Spoons",
                  style: TextStyle(color: Colors.white)
              ),
              leading: CircleAvatar(
                  child: Image.asset('assests/Tablespoon.png', width:20, height:20)),
              backgroundColor: Colors.white,
              collapsedBackgroundColor: Colors.blueAccent,
              children:<Widget>[
                ListView(
                  scrollDirection: Axis.vertical,

                  shrinkWrap: true,// <-- Like so
                  //controller: _scrollController,
                  //physics: NeverScrollableScrollPhysics(),
                  children: <Widget>[
                    ExpansionTile(
                    title: Text("Common"),
                    children:<Widget>[
                      Container(
                      //width: 160.0,
                      //color: Colors.red,
                      child: Image.asset(
                        'assests/Teaspoon/T5.jpg', width:200,height:200 ),
                    )]),
                    ExpansionTile(
                        title: Text("1 Tablespoon"),
                        children:<Widget>[
                          Container(
                            //width: 160.0,
                            //color: Colors.red,
                            child: Image.asset('assests/Teaspoon/T1.jpg',width:150,height:150 ),
                          )]),
                    ExpansionTile(
                        title: Text("1 Teaspoon"),
                        children:<Widget>[
                          Container(
                            //width: 160.0,
                            //color: Colors.red,
                              child: Image.asset('assests/Teaspoon/T2.jpg', width:150,height:150)
                          )]),
                    ExpansionTile(
                        title: Text("Half Teaspoon"),
                        children:<Widget>[
                          Container(
                            //width: 160.0,
                            //color: Colors.red,
                              child: Image.asset('assests/Teaspoon/T3.jpg',width:150,height:150)
                          )]),
                    ExpansionTile(
                        title: Text("One-fourth Teaspoon"),
                        children:<Widget>[
                          Container(
                            //width: 160.0,
                            //color: Colors.red,
                              child: Image.asset('assests/Teaspoon/T4.jpg',width:150,height:150)
                          )]),
                  ],
                )
              ]
          ),
          const SizedBox(
            //Use of SizedBox
            height: 6,
          ),
          ExpansionTile(
              title: Text(
                "Cup",
                  style: TextStyle(color: Colors.white)
              ),
              leading: CircleAvatar(
                  child: Image.asset('assests/Cup.png', width:20, height:20)),
              backgroundColor: Colors.white,
              collapsedBackgroundColor: Colors.blueAccent,
              children:<Widget>[
                ListView(
                  scrollDirection: Axis.vertical,

                  shrinkWrap: true,// <-- Like so
                  //controller: _scrollController,
                  //physics: NeverScrollableScrollPhysics(),
                  children: <Widget>[

                    ExpansionTile(
                        title: Text("1 Cup"),
                        children:<Widget>[
                          Container(
                            //width: 160.0,
                            //color: Colors.red,
                            child: Image.asset(
                                'assests/cup/IMG_5136.jpg', width:200,height:200, scale: 1.0, ),
                          )]),

                  ],
                )
              ]
          ),
          const SizedBox(
            //Use of SizedBox
            height: 6,
          ),
          ExpansionTile(
              title: Text(
                  "katori",
                  style: TextStyle(color: Colors.white)
              ),
              leading: CircleAvatar(
                  child: Image.asset('assests/Bowl.png', width:20, height:20)),
              backgroundColor: Colors.white,
              collapsedBackgroundColor: Colors.blueAccent,
              children:<Widget>[
                ListView(
                  scrollDirection: Axis.vertical,

                  shrinkWrap: true,// <-- Like so
                  //controller: _scrollController,
                  //physics: NeverScrollableScrollPhysics(),
                  children: <Widget>[

                    ExpansionTile(
                        title: Text("1 katori"),
                        children:<Widget>[
                          Container(
                            //width: 160.0,
                            //color: Colors.red,
                            child: Image.asset(
                                'assests/katori/IMG_5116.jpg', width:200,height:200 ),
                          )]),

                  ],
                )
              ]
          ),
          const SizedBox(
            //Use of SizedBox
            height: 6,
          ),
          ElevatedButton(
            onPressed: () => {
              // We need to prepare the test PDF, and then we can display the PDF.
              prepareTestPdf().then((path) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => FullPdfViewerScreen(path)),
                );
              })
            },
            child: const Text('Open Flip Book'),
          ),
        ]
      )

      );

  }
}

class FullPdfViewerScreen extends StatelessWidget {
  final String pdfPath;

  FullPdfViewerScreen(this.pdfPath);

  @override
  Widget build(BuildContext context) {
    return Container(
        width: 500,
        height: 500,
        child:PDFViewerScaffold(
        appBar: AppBar(
          title: Text("Flip Book"),
        ),
        path: pdfPath));
  }
}


class DataAnalyze extends StatelessWidget {
  DataAnalyze({Key? key, required this.patientlist}) : super(key: key);
  final List<Map<String, dynamic>> lst = [];
  final List<String> temp = [];
  final List<String> patientlist;
  //final List<String> p= patientlist;
  String selectedPatient = "";
  String nm = "";
  List<String> str = [];
  List<String> s = [];
  Map<String,dynamic> result = {};
  List<Map<String, dynamic>> fin = [];
  List<Map<String, dynamic>> tst = [];
  List<ChartData> fData=[];
  List<ChartData> fData1=[];
  List<List<ChartData>> finalData = [];
  List<String> dates = [];
  List<Widget> finalLst = [];

  Future<void> readNutrient(String selectedPatient) async {
    lst.clear();
    var url = "https://foodapp-5369f-default-rtdb.firebaseio.com/NutrientInfo.json";
    try {
      final response = await http.get(Uri.parse(url));
      final extractedData = json.decode(response.body) as Map<String, dynamic>;
      print(extractedData);
      if (extractedData == null) {
        return;
      }
      extractedData.forEach((key, value) {
        if(value["PatientId"] == selectedPatient){
          lst.add(value);
          temp.add(value.toString());
          tst.add(value);
          print("tempMap");
        }
      });
    } catch (error) {
      throw error;
    }
  }

  List<ChartData> intoourdata(){
    List<ChartData> temp = [];
    //fData.clear();
    print("tst[0]: ");
    print(tst[0]);
    tst[0].forEach((key, value) {
      if(key !="PatientId" && key != "date"){
        temp.add(ChartData(key,value));
      }
    });
    return temp;
  }

  void intoourdata2(){
    for(int i = 0;i<tst.length;i++){
      List<ChartData> temp = [];
      //fData.clear();
      //print("tst[0]: ");
      //print(tst[0]);
      //fin.forEach((element) {
      tst[i].forEach((key, value) {
        if(key !="PatientId" && key != "date"){
          //print(key);
          //print(value);
          //print(value);
          //print(ChartData(key, value));
          temp.add(ChartData(key,value));
        }
      });
      finalData.add(temp);
      dates.add(tst[i]["date"] ?? "00-00-00");
    }
    //});
    //return temp;
  }

  List<ChartData> intoourdata1(){
    List<ChartData> temp = [];
    //fData.clear();
    print("tst[1]: ");
    print(tst[1]);
    //fin.forEach((element) {
    tst[1].forEach((key, value) {
      if(key !="PatientId" && key != "date"){
        //print(key);
        //print(value);
        //print(value);
        //print(ChartData(key, value));
        temp.add(ChartData(key,value));
      }
    });
    //});
    return temp;
  }

  void makeLst(){
    for(int i = 0;i<finalData.length;i++){
      finalLst.add(Text(dates[i]));
      finalLst.add(
          SfCartesianChart(
              primaryXAxis: CategoryAxis(
                  title: AxisTitle(
                      text: 'Nutrients',
                      textStyle: const TextStyle(
                          color: Colors.deepOrange,
                          fontFamily: 'Roboto',
                          fontSize: 8,
                          fontStyle: FontStyle.italic,
                          fontWeight: FontWeight.w300
                      )
                  )
              ),
              series: <BarSeries<ChartData, String>>[
                // Initialize line series
                BarSeries<ChartData, String>(
                    isVisible: true,
                    dataSource: finalData[i],
                    xValueMapper: (ChartData data, _) => data.x,
                    yValueMapper: (ChartData data, _) => data.y
                )
              ]
          )
      );
    }

  }


  @override
  Widget build(BuildContext context) {

    return Scaffold(
        appBar: AppBar(
          title: const Text("IITJ Diet"),
          centerTitle: true,
          backgroundColor: Colors.blue[300],
        ),
        body: ListView(
          children: <Widget>[
            DropdownSearch<String>(
              popupProps: const PopupProps.menu(
                showSearchBox: true,
                showSelectedItems: true,
              ),
              items: patientlist,
              dropdownDecoratorProps: const DropDownDecoratorProps(
                dropdownSearchDecoration: InputDecoration(
                    labelText: "PatientList",
                    hintText: "Patients"
                ),
              ),
              onChanged: (val){
                selectedPatient = val.toString();
                print(selectedPatient);
              },
            ),
            ElevatedButton(
                onPressed: (){
                  temp.clear();

                  //intoourdata();
                  //print("ourData:");
                  //print(fData);
                  if(selectedPatient != ""){
                    readNutrient(selectedPatient).then((value)=>{
                      fin.clear(),
                      print("Final tst: "),
                      print(tst),
                      //print(json.encode(temp[0])),
                      //print(fin),
                      fData.clear(),
                      fData1.clear(),
                      //print("Empty: "),
                      //print(fData),
                      intoourdata2(),
                      makeLst(),
                      fData = intoourdata(),
                      if(tst.isNotEmpty){
                        Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => MultiGraph(finalLst: finalLst, patientlist: patientlist))
                        )
                      },
                      /*if(tst.length > 1){
                        fData1 = intoourdata1()
                      },*/
                      print("Full: "),
                      print(fData),
                      /*if(fData1.isNotEmpty){
                        Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => FinalData1(dataList: temp, dataMap: fin, ourdata: fData, ourdata1: fData1, finalLst: finalLst, t0: tst[0]['date'], t1: tst[1]['date']))
                        )
                      }
                      else{
                        Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => FinalData(dataList: temp, dataMap: fin, ourdata: fData, t0: tst[0]['date']))
                        )
                      },*/
                    });
                  }
                },
                child: Text("Get Info")
            ),

          ],
        )
    );
  }
}

class MultiGraph extends StatelessWidget {
  MultiGraph({Key? key, required this.finalLst, required this.patientlist}) : super(key: key);
  List<Widget> finalLst;
  final List<String> patientlist;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("IITJ Diet"),
        centerTitle: true,
        backgroundColor: Colors.blue[300],
        automaticallyImplyLeading: false,
      ),
      body: ListView(
        children: finalLst,
      ),
      floatingActionButton: ElevatedButton(onPressed:(){
        Navigator.pop(context);
        Navigator.pop(context);
        Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => DataAnalyze(patientlist: patientlist))
        );
      },
          child: Text("Back")
      ),
    );
  }
}


class FinalData extends StatelessWidget {
  FinalData({Key? key, required this.dataList, required this.dataMap, required this.ourdata, required this.t0 }) : super(key: key);
  String getPrettyJSONString(jsonObject){
    var encoder = new JsonEncoder.withIndent("     ");
    return encoder.convert(jsonObject);
  }
  final List<String> dataList;
  final List<Map<String,dynamic>> dataMap;
  final List<ChartData> ourdata;
  final List<ChartData> ourdata1 = [];
  final String t0;
  //String id = dataMap[0]["PatientId"];





  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text("IITJ Diet"),
          centerTitle: true,
          backgroundColor: Colors.blue[300],
        ),
        body:ListView(

            children:<Widget>[
              /*ListView(
          //shrinkWrap: true,
            scrollDirection: Axis.vertical,
            shrinkWrap: true,
        children: dataList.map((strone){
        return Container(
          margin: EdgeInsets.all(5),
          padding: EdgeInsets.all(15),
          //color: Colors.green[100],
          child: Text(
            getPrettyJSONString(strone),
            style: TextStyle(height: 5, fontSize: 10),
          ),
        );
      }).toList(),
      ),*/
              const Text("\n\n Y axis : Amount of nutrient\n X: axis: Name of nutrient\n\n"),
              Text(t0),
              const Text("\n\n"),
              SfCartesianChart(
                  primaryXAxis: CategoryAxis(
                      title: AxisTitle(
                          text: '',
                          textStyle: const TextStyle(
                              color: Colors.deepOrange,
                              fontFamily: 'Roboto',
                              fontSize: 8,
                              fontStyle: FontStyle.italic,
                              fontWeight: FontWeight.w300
                          )
                      )
                  ),
                  series: <BarSeries<ChartData, String>>[
                    // Initialize line series
                    BarSeries<ChartData, String>(
                        isVisible: true,
                        dataSource: ourdata,
                        xValueMapper: (ChartData data, _) => data.x,
                        yValueMapper: (ChartData data, _) => data.y
                    )
                  ]
              ),
              /*SfCartesianChart(
              primaryXAxis: CategoryAxis(
                  title: AxisTitle(
                      text: 'X-Axis',
                      textStyle: const TextStyle(
                          color: Colors.deepOrange,
                          fontFamily: 'Roboto',
                          fontSize: 8,
                          fontStyle: FontStyle.italic,
                          fontWeight: FontWeight.w300
                      )
              )),
              series: <ChartSeries>[
                // Initialize line series
                LineSeries<ChartData, String>(
                    isVisible: true,
                    dataSource: ourdata1,
                    xValueMapper: (ChartData data, _) => data.x,
                    yValueMapper: (ChartData data, _) => data.y
                )
              ]
          ),*/

              ElevatedButton(
                  onPressed: (){
                    int count = 0;
                    Navigator.of(context).popUntil((_) => count++ >= 2);
                  },
                  child: Text("Back")
              )


            ]
        )
    );

  }
}

class FinalData1 extends StatelessWidget {
  FinalData1({Key? key, required this.dataList, required this.dataMap, required this.ourdata, required this.ourdata1, required this.finalLst, required this.t0, required this.t1}) : super(key: key);
  String getPrettyJSONString(jsonObject){
    var encoder = new JsonEncoder.withIndent("     ");
    return encoder.convert(jsonObject);
  }
  final List<String> dataList;
  final List<Map<String,dynamic>> dataMap;
  final List<ChartData> ourdata;
  final List<ChartData> ourdata1;
  final List<Widget> finalLst;
  final String t0;
  final String t1;
  //String id = dataMap[0]["PatientId"];




  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text("IITJ Diet"),
          centerTitle: true,
          backgroundColor: Colors.blue[300],
        ),
        body:ListView(

            children:<Widget>[
              /*ListView(
                //shrinkWrap: true,
                scrollDirection: Axis.vertical,
                shrinkWrap: true,
                children: dataList.map((strone){
                  return Container(
                    margin: EdgeInsets.all(5),
                    padding: EdgeInsets.all(15),
                    //color: Colors.green[100],
                    child: Text(
                      getPrettyJSONString(strone),
                      style: TextStyle(height: 5, fontSize: 10),
                    ),
                  );
                }).toList(),
              ),*/
              const Text("\n\n Y axis : Amount of nutrient\n X: axis: Name of nutrient\n\n"),
              Text(t0),
              const Text("\n\n"),
              SfCartesianChart(
                  primaryXAxis: CategoryAxis(
                      title: AxisTitle(
                          text: '',
                          textStyle: const TextStyle(
                              color: Colors.deepOrange,
                              fontFamily: 'Roboto',
                              fontSize: 8,
                              fontStyle: FontStyle.italic,
                              fontWeight: FontWeight.w300
                          )
                      )
                  ),

                  series: <BarSeries<ChartData, String>>[
                    // Initialize line series
                    BarSeries<ChartData, String>(
                        isVisible: true,
                        dataSource: ourdata,
                        xValueMapper: (ChartData data, _) => data.x,
                        yValueMapper: (ChartData data, _) => data.y
                    )
                  ]
              ),
              const Text("\n\n"),
              Text(t1),
              const Text("\n\n"),
              SfCartesianChart(
                  primaryXAxis: CategoryAxis(
                      title: AxisTitle(
                          text: '',
                          textStyle: const TextStyle(
                              color: Colors.deepOrange,
                              fontFamily: 'Roboto',
                              fontSize: 8,
                              fontStyle: FontStyle.italic,
                              fontWeight: FontWeight.w300
                          )
                      )),
                  series: <BarSeries<ChartData, String>>[
                    // Initialize line series
                    BarSeries<ChartData, String>(
                        isVisible: true,
                        dataSource: ourdata1,
                        xValueMapper: (ChartData data, _) => data.x,
                        yValueMapper: (ChartData data, _) => data.y
                    )
                  ]
              ),

              ElevatedButton(
                  onPressed: (){
                    int count = 0;
                    Navigator.of(context).popUntil((_) => count++ >= 2);
                  },
                  child: Text("Back")
              )


            ]
        )
    );

  }
}


class ChartData {
  ChartData(this.x, this.y);
  final String x;
  final num? y;
}
