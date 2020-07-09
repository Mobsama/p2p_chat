import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_plugin_record/flutter_plugin_record.dart';
import 'package:fluttertoast/fluttertoast.dart';

class Voice extends StatefulWidget {
  final Function startRecord;
  final Function stopRecord;

  const Voice({Key key, this.startRecord, this.stopRecord})
      : super(key: key);
  @override
  _VoiceState createState() => _VoiceState();
}

class _VoiceState extends State<Voice> {
  var _tapDownTime;
  var _state = 0;
  var _textShow = '按住 说话';
  var _flag = true;

  Color voiceColor = Colors.white;

  OverlayEntry _overlayEntry;
  FlutterPluginRecord recordPlugin;

  @override
  void initState(){
    super.initState();
    recordPlugin = FlutterPluginRecord();
    _init();

    recordPlugin.response.listen((data) {
      if (data.msg == "onStop") {
        sleep(Duration(microseconds: 200));
        widget.stopRecord(data.path,_flag);
      } else if (data.msg == "onStart") {
        widget.startRecord();
      }
    });

    recordPlugin.responseFromAmplitude.listen((data) {
      var voiceData = double.parse(data.msg);
      setState(() {
        if (voiceData > 0 && voiceData < 0.1) {
          voiceColor = Colors.white10;
        } else if (voiceData > 0.2 && voiceData < 0.3) {
          voiceColor = Colors.white24;
        } else if (voiceData > 0.3 && voiceData < 0.4) {
          voiceColor = Colors.white30;
        } else if (voiceData > 0.4 && voiceData < 0.5) {
          voiceColor = Colors.white38;
        } else if (voiceData > 0.5 && voiceData < 0.6) {
          voiceColor = Colors.white54;
        } else if (voiceData > 0.6 && voiceData < 0.7) {
          voiceColor = Colors.white60;
        } else if (voiceData > 0.7 && voiceData < 1) {
          voiceColor = Colors.white70;
        } else {
          voiceColor = Colors.white;
        }
        if (_overlayEntry != null) {
          _overlayEntry.markNeedsBuild();
        }
      });
    });

  }

  @override
  void dispose(){
    recordPlugin.dispose();
    super.dispose();
  }

  @override
  Widget build(context) {
    return Container(
      child: GestureDetector(
        onTapDown: (details){
          _tapDownTime = DateTime.now();
          setState(() {
            _flag = true;
            _state = 1;
            _textShow = '松开 发送';
          });
          buildOverLayView(context);
          _start();
        },
        onTapUp: (details){
          if(DateTime.now().difference(_tapDownTime).inMilliseconds < 500){
            Fluttertoast.showToast(
                msg: "说话时间太短",
                toastLength: Toast.LENGTH_SHORT,
                gravity: ToastGravity.BOTTOM,
                timeInSecForIosWeb: 1,
                fontSize: 16.0
            );
            setState(() {
              _flag = false;
            });
          }
          setState(() {
            _state = 0;
            _textShow = '按住 说话';
          });
          if (_overlayEntry != null) {
            _overlayEntry.remove();
            _overlayEntry = null;
          }
          sleep(Duration(microseconds: 2000));
          recordPlugin.stop();
        },
        onVerticalDragUpdate: (details){
          setState(() {
            _state = 2;
            _textShow = '取消 发送';
            _flag = false;
            if(_overlayEntry!=null)
              _overlayEntry.markNeedsBuild();
          });
        },
        onVerticalDragEnd: (details){
          setState(() {
            _state = 0;
            _textShow = '按住 说话';
          });
          if (_overlayEntry != null) {
            _overlayEntry.remove();
            _overlayEntry = null;
          }
          sleep(Duration(microseconds: 2000));
          recordPlugin.stop();
        },
        child: Container(
          decoration: BoxDecoration(
            border: Border.all(width: 1,color: Colors.grey),
            borderRadius: BorderRadius.all(Radius.circular(8.0)),
            color: _state!=0?Colors.grey[500]:Colors.white
          ),
          height: 50,
          margin: EdgeInsets.fromLTRB(10, 0, 10, 2),
          child: Center(
            child: Text(
              _textShow,
            ),
          ),
        ),
      ),
    );
  }

  buildOverLayView(context){
    if(_overlayEntry == null) {
      _overlayEntry = OverlayEntry(builder: (BuildContext context) =>
          Positioned(
            child: Material(
              type: MaterialType.transparency,
              child: Center(
                child: Opacity(
                  opacity: 0.8,
                  child: Container(
                    width: 160,
                    height: 160,
                    decoration: BoxDecoration(
                      color: Color(0xff77797A),
                      borderRadius: BorderRadius.all(Radius.circular(20.0)),
                    ),
                    child: Column(
                      children: <Widget>[
                        Expanded(
                          child: Container(
                            child: Icon(_state==2?Icons.undo:Icons.mic,size: 100,color: _state==2?Colors.white:voiceColor,)
                          ),
                        ),
                        Container(
                          margin: EdgeInsets.only(bottom: 10),
                          child: Text(
                            _textShow,
                            style: TextStyle(
                              fontStyle: FontStyle.normal,
                              color: Colors.white,
                              fontSize: 14,
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                ),
              ),
            ),
          )
      );
      Overlay.of(context).insert(_overlayEntry);
    }
  }

  ///初始化语音录制的方法
  void _init() async {
    recordPlugin.init();
  }

  ///开始语音录制的方法
  void _start() async {
    recordPlugin.start();
  }
}
