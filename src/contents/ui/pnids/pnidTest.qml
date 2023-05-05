import QtQuick 2.15
import QtQuick.Controls 2.15 as Controls
import QtQuick.Layouts 1.15
import QtQuick.Shapes 1.15
import org.kde.kirigami 2.20 as Kirigami
import "components"
import "pnid_elements"

Item {
    id: pnidTest

    ValveSolenoid {
        id: testSolenoid
        x: 20
        y: 30
    }

    ValveSolenoid {
        id: testSolenoid2
        x: 100
        y: 30
    }
}
