import QtQuick 2.0
import QtQuick.Controls 1.0
import QtQuick.Layouts 1.0
import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.components 2.0 as PlasmaComponents
import org.kde.plasma.extras 2.0 as PlasmaExtras
import org.kde.plasma.plasmoid 2.0
Item {
	id: page
	property alias cfg_tamano: slide.value
	ColumnLayout {
		    
	    
		Label{
			text:"Size: "+slide.value+"x"+slide.value
		}
		RowLayout {
			Label{
				text:"2x2"
			}
			Slider {
				id: slide
				minimumValue: 2
				maximumValue: 9
				stepSize: 1
				tickmarksEnabled: true
			}
			Label{
				text:"9x9"
			}
		}
	}

}
