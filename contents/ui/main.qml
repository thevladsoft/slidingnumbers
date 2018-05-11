/*
 *   Copyright 2017 thevladsoft <thevladsoft2@gmail.com>
 *
 *
 *   This program is free software; you can redistribute it and/or modify
 *   it under the terms of the GNU Library General Public License as
 *   published by the Free Software Foundation; either version 2 or
 *   (at your option) any later version.
 *
 *   This program is distributed in the hope that it will be useful,
 *   but WITHOUT ANY WARRANTY; without even the implied warranty of
 *   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *   GNU General Public License for more details
 *
 *   You should have received a copy of the GNU Library General Public
 *   License along with this program; if not, write to the
 *   Free Software Foundation, Inc.,
 */

import QtQuick 2.0;
import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.components 2.0 as PlasmaComponents
import QtQuick.Controls 1.4 as QtControls
import org.kde.plasma.plasmoid 2.0
import QtWebKit 3.0
import QtQuick.Dialogs 1.2
import QtQuick.Layouts 1.1 as QtLayouts
import QtQuick.Controls.Styles 1.4

Item {
    id:root

    width: 350
    property var arreglo: []
    property var vecinos: []
    property var cuadros: []
    property int pasos
    property int ancho: plasmoid.configuration.tamano//2/***********/
    property int alto: ancho//2/*************/
    
    Component.onCompleted:{
        inicializar()
		plasmoid.setAction("inicializa", i18n("Restart"));
    }
    
    function action_inicializa() {
        inicializar()
    }

    Connections {
        target: plasmoid.configuration
        onTamanoChanged: {inicializar()}
    }
    
    function shuffleArray(array) {
        for (var i = array.length - 2; i > 0; i--) {
            var j = Math.floor(Math.random() * (i + 1));
            var temp = array[i];
            array[i] = array[j];
            array[j] = temp;
        }
    }
    function buscaVecinos(array){//crea numeros enteros grandes, pero no creo que produzca error
        var left = array.slice(1).map(function(num,index) {
            if (index % (ancho) == ancho-1) {return 1}
            else {return num}
        })
        left.push(1)
        
        var right = array.slice(0,-1)
        right.splice(0,0,1)
        right = right.map(function(num,index) {
            if (index % (ancho) == 0) {return 1}
            else {return num}
        })
        
        var up = array.slice(ancho)
        for(var i=0;i<ancho;i++){
            up.push(1)
        }
        
        var down = array.slice(0,-ancho)
        for(var i=0;i<ancho;i++){
            down.unshift(1)
        }
        
		//...
		
		var result = []
        for(var i = 0; i<ancho*alto;i++){
            result[i]=left[i]*right[i]*up[i]*down[i]
        }
//         print(result)
        return result
    }
    
    function inicializar(){
        arreglo = []
        pasos = 0
        covertura.visible=false
        
        for (var i = 0; i<ancho*alto-1;i++){
            arreglo[i]=i+1
        }
//         print(arreglo)
        var solvable=false
        while (!solvable || isordered(arreglo,false)){
            shuffleArray(arreglo)
            arreglo[ancho*alto-1]=0
            solvable = isSolvable(arreglo)
        }
//         print(isSolvable(arreglo))
        
        vecinos = buscaVecinos(arreglo)
        
        for (var i = 0; i<cuadros.length;i++){
            cuadros[i].destroy()
        }
        cuadros = []
        for (var i = 0; i<ancho*alto-1;i++){
            cuadros[i] = Qt.createQmlObject('import QtQuick 2.0; \
            Rectangle {\
              property var texto:"'+(i+1)+'";\
              color: "transparent";border.color: "black";\
              width: Math.floor(root.width/ancho)-1; height: Math.floor(root.height/alto)-1;\
              x:0; y:0;\
              MouseArea {\
                anchors.fill: parent;\
                onClicked:{rectangleclicked('+i+',arreglo)}\
              }\
              Behavior on x {\
                NumberAnimation {\
                  duration: 300 }\
              }\
              Behavior on y {\
                NumberAnimation { duration: 300 }\
              }\
              Text{\
                text:parent.texto;\
                horizontalAlignment:Text.AlignHCenter; verticalAlignment:Text.AlignVCenter;\
                width:parent.width;height:parent.height;\
                font.pixelSize: parent.height<parent.width?parent.height:parent.width}\
            }', fondo,"dynamicSnippet1");
        //print (newObject.x);
        }
        reposiciona(cuadros)
        
//         print(isSolvable(arreglo))
        
    }
    
    function reposiciona(arr){
        for (var i = 0; i<arr.length;i++){
            arr[i].x=(arreglo.indexOf(i+1)%ancho*Math.floor(root.width/ancho))
//             arr[i].width=Math.floor(root.width/ancho)-1
            arr[i].y=(Math.floor(arreglo.indexOf(i+1)/ancho))*Math.floor(root.height/alto)
//             arr[i].height=Math.floor(root.height/alto)-1
        }
//         print(arreglo)
    }
    
	function isSolvable(puzzle){
		    var parity = 0
		    var gridWidth = Math.floor(Math.sqrt(puzzle.length))//(int) Math.sqrt(puzzle.length)//Vlad cambiar esto a javascript
		    var row = 0 // the current row we are on
		    var blankRow = 0; // the row with the blank tile

		    for (var i = 0; i < puzzle.length; i++){
		        if (i % gridWidth == 0) { // advance to next row
		            row++;
		        }
		        if (puzzle[i] == 0) { // the blank tile
		            blankRow = row; // save the row on which encountered
		            continue;//Vlad se debe cambiar??
		        }
		        for (var j = i + 1; j < puzzle.length; j++)
		        {
		            if (puzzle[i] > puzzle[j] && puzzle[j] != 0)
		            {
		                parity++;
		            }
		        }
		    }

		    if (gridWidth % 2 == 0) { // even grid
		        if (blankRow % 2 == 0) { // blank on odd row; counting from bottom
		            return parity % 2 == 0;
		        } else { // blank on even row; counting from bottom
		            return parity % 2 != 0;
		        }
		    } else { // odd grid
		        return parity % 2 == 0;
		    }
	}
	
	function rectangleclicked(j,arreglo){
        var i=arreglo.indexOf(j+1)
//         print(vecinos,i,j,cuadros[j].texto,vecinos[i],arreglo[i])
        if (!vecinos[i]){
			pasos+=1;
            arreglo[arreglo.indexOf(0)]=arreglo[i]
            arreglo[i]=0
            vecinos = buscaVecinos(arreglo)
            reposiciona(cuadros)
//             print(arreglo)
        }
        if(isordered(arreglo)){covertura.visible=true}
    }
    
    function isordered(arr,ceroend){
        ceroend = ceroend || 1
        var gane=true
//         print("--",ancho*alto-1-ceroend)
        for (var i = 0; i<ancho*alto-1-ceroend;i++){
            if(arr[i+1]<arr[i]){gane=false}
        }
        if(ceroend){
            if(arr[ancho*alto-1] && arr[ancho*alto-1]<arr[ancho*alto-2]){
                gane=false
            }
        }
//         print(arreglo)
        if(gane){//print("Gane")
            return true
        }else{
            return false
        }
    }

    
    Rectangle {
        id: fondo
        width: root.width; height: root.height
        color: "white"
        border.color:"black"
        border.width:1
        
        
        onWidthChanged:{reposiciona(cuadros)}
        onHeightChanged:{reposiciona(cuadros)}
    
        MouseArea {
            anchors.fill: parent
            onClicked: {
            }
        }
        
        Rectangle {
            id: covertura
            width: root.width; height: root.height
            color: "lightgray"
            border.color:"red"
            border.width:3
            z:1000
            
            visible:false
            
            opacity: visible?0.85:0.0;
            Behavior on opacity{ 
                NumberAnimation { duration: 700;easing.type:Easing.InExpo}
                
            }
            
            Text{
                text:"YOU WIN\nin "+pasos+" steps\n\nClick to restart";
                horizontalAlignment:Text.AlignHCenter; 
                verticalAlignment:Text.AlignVCenter;
                width:parent.width;
                height:parent.height; 
                color: "white"
                styleColor : "red"
//                 font.bold : true
                style: Text.Outline
                font.letterSpacing: 1
                elide: Text.ElideMiddle
                font.weight: Font.ExtraBold
               font.pointSize: 12
            }
            MouseArea {
                anchors.fill: parent
                onClicked: {
//                     covertura.visible=false
                    inicializar()
                }
            }
        }
        
    }


  
  
}

    

// PlasmaCore.ToolTipArea{
//             id:tooltip
//             active:false
//                             mainText: "heya"
//                             width: root.width; height: root.height
//                  image:"/home/.../linein_2.png"
//                  z:1000
