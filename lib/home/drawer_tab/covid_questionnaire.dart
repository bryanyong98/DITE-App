import 'package:flutter/material.dart';
import 'package:heard/constants.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_fonts/google_fonts.dart';

final List<String> images = <String>[
  'images/gif/1.1.gif',
  'images/gif/1.2.gif',
  'images/gif/1.3.gif',
  'images/gif/1.4.gif',
  'images/gif/1.5.gif',
  'images/gif/1.6.gif',
  'images/gif/2.1.gif',
  'images/gif/2.2.gif',
  'images/gif/2.3.gif',
  'images/gif/3.2.gif',
  'images/gif/3.3.gif',
  'images/gif/3.4.gif',
  'images/gif/3.5.gif',
  'images/gif/4.1.gif',
  'images/gif/4.2.gif',
  'images/gif/4.3.gif',
  'images/gif/4.4.gif',
  'images/gif/4.5.gif',
  'images/gif/4.6.gif',
  'images/gif/4.7.gif',
  'images/gif/4.8.gif',
  'images/gif/4.9.gif'  ];

final List<String> questions = <String>[
  "Adakah anda mengalami gejala-gejala ini dalam tempoh 14 hari yang lepas?\n",
  "Batuk\n",
  'Demam\n',
  'Sakit tekak\n',
  'Selesema\n',
  'Sesak nafas\n',
  'Dalam tempoh 14 hari yang lepas\n',
  'Adakah anda pernah melawat negara luar Malaysia?\n',
  'Jika ya, nyatakan\n',
  'Adakah anda pernah terlibat dalam mana-mana perhimpunan?\n',
  'Ijtimak tabligh\n',
  'Majlis perkahwinan\n',
  'Lain-lain\n',
  'Adakah anda ada kontak rapat dengan pesakit positif COVID-19 sebelum peasakit tersebut mengalami simptom?\n',
  'Jika ya, berapa hari lepas anda berjumpa dengan pesakit tersebut?\n',
  'Adakah anda duduk serumah dengan pesakit tersebut?\n',
  'Melawat perhimpunan kecil yang dihadiri pesakit yang disahkan COVID-19?\n',
  'Bersemuka melebihi 15 minit dalam jarak kurang 1 meter dengan pesakit yang disahkan COVID-19?\n',
  'Berada dalam ruangan tertutup selama lebih dari 2 jam dengan pesakit yang disahkan COVID-19?\n',
  'Menaiki kenderaan yang sama melebihi 2 jam dengan pesakit yang disahkan COVID-19?\n',
  'Siapakah mereka_ Apakah hubungan anda dengan mereka?\n',
  'Kami memerlukan nombor-nombor orang yang dekat dengan mereka\n'
];

class Questionnaire extends StatefulWidget {
  @override
  _QuestionnaireState createState() => _QuestionnaireState();
}

class _QuestionnaireState extends State<Questionnaire> {

  bool isSLI = false ;
  final TextEditingController _controller = new TextEditingController();
  List<String> questionFilterList;
  List<String> imageFilterList;

  @override
  void initState() {
    super.initState();
    setSLI();
    print(isSLI);
  }

  void setSLI() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    setState(() {
      isSLI = preferences.getBool('isSLI');
    });
  }

  void filterQuestionnaire({String text}) {
    questionFilterList = [];
    imageFilterList = [];
    for (int index = 0; index < questions.length; index++) {
      if (questions[index].toLowerCase().contains(text.toLowerCase())) {
        questionFilterList.add(questions[index]);
        imageFilterList.add(images[index]);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (questionFilterList == null && imageFilterList == null) {
      filterQuestionnaire(text: '');
    }
    return Scaffold(
      appBar: AppBar(
        backgroundColor: isSLI ? Colours.orange : Colours.blue,
        title: Text('Soal Selidik Covid-19',
          style: GoogleFonts.lato(
          fontSize: FontSizes.mainTitle,
          fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
          children: <Widget>[
            Container(
              height: Dimensions.d_95,
              child: TextField(
               controller: _controller,
                onChanged: (String text) {
                 setState(() {
                   filterQuestionnaire(text: text);
                 });
                },
                decoration: InputDecoration(
                    fillColor: Colours.grey,
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(
                                          Radius.circular(Dimensions.d_30),
                        ),
                    ),
                    labelText: 'Cari Kata Kunci',
                    icon: Icon(Icons.search, color: Colours.black, size: Dimensions.d_25,),
                  ),
                ),
              padding: EdgeInsets.all(Dimensions.d_25),
            ),
            Divider(
              height: Dimensions.d_0,
              thickness: Dimensions.d_10,
              color: Colours.lightGrey,
            ),
            /* Construct a list of questions for the users for viewing */
            Expanded(
              child: ListView.separated(
                padding: EdgeInsets.all(Dimensions.d_10),
                itemCount: questionFilterList.length,
                itemBuilder: (BuildContext context, int index) {
                  return Container(
                    margin: EdgeInsets.symmetric(vertical: Dimensions.d_20),
                    child: ListTile(

                      title: Text(
                        '${questionFilterList[index]}',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),

                      subtitle: Image(image: AssetImage(imageFilterList[index]),),
                    ),
                  );
                },
                separatorBuilder: (BuildContext context, int index) => Divider(
                  height: Dimensions.d_2,
                  thickness: Dimensions.d_2*2,
                  color: Colours.grey,
                )
              ),
            ),
          ],
        ),
    );
  }
}
