# -*- coding: utf-8 -*-

# Form implementation generated from reading ui file 'diagnostic_metrics.ui'
#
# Created: Mon Aug 08 14:51:25 2011
#      by: PyQt4 UI code generator 4.8.3
#
# WARNING! All changes made in this file will be lost!

from PyQt4 import QtCore, QtGui

try:
    _fromUtf8 = QtCore.QString.fromUtf8
except AttributeError:
    _fromUtf8 = lambda s: s

class Ui_diag_metric(object):
    def setupUi(self, diag_metric):
        diag_metric.setObjectName(_fromUtf8("diag_metric"))
        diag_metric.setWindowModality(QtCore.Qt.ApplicationModal)
        diag_metric.resize(365, 147)
        diag_metric.setMinimumSize(QtCore.QSize(365, 140))
        diag_metric.setMaximumSize(QtCore.QSize(367, 147))
        font = QtGui.QFont()
        font.setFamily(_fromUtf8("Verdana"))
        diag_metric.setFont(font)
        icon = QtGui.QIcon()
        icon.addPixmap(QtGui.QPixmap(_fromUtf8(":/images/meta.png")), QtGui.QIcon.Normal, QtGui.QIcon.Off)
        diag_metric.setWindowIcon(icon)
        self.formLayout_2 = QtGui.QFormLayout(diag_metric)
        self.formLayout_2.setObjectName(_fromUtf8("formLayout_2"))
        self.metrics_grp_box = QtGui.QGroupBox(diag_metric)
        self.metrics_grp_box.setObjectName(_fromUtf8("metrics_grp_box"))
        self.verticalLayout = QtGui.QVBoxLayout(self.metrics_grp_box)
        self.verticalLayout.setObjectName(_fromUtf8("verticalLayout"))
        self.gridLayout = QtGui.QGridLayout()
        self.gridLayout.setObjectName(_fromUtf8("gridLayout"))
        self.chk_box_sens = QtGui.QCheckBox(self.metrics_grp_box)
        self.chk_box_sens.setChecked(True)
        self.chk_box_sens.setObjectName(_fromUtf8("chk_box_sens"))
        self.gridLayout.addWidget(self.chk_box_sens, 0, 0, 1, 1)
        self.chk_box_spec = QtGui.QCheckBox(self.metrics_grp_box)
        self.chk_box_spec.setChecked(True)
        self.chk_box_spec.setObjectName(_fromUtf8("chk_box_spec"))
        self.gridLayout.addWidget(self.chk_box_spec, 0, 1, 1, 1)
        self.chk_bo_plr = QtGui.QCheckBox(self.metrics_grp_box)
        self.chk_bo_plr.setObjectName(_fromUtf8("chk_bo_plr"))
        self.gridLayout.addWidget(self.chk_bo_plr, 1, 0, 1, 1)
        self.chk_box_nlr = QtGui.QCheckBox(self.metrics_grp_box)
        self.chk_box_nlr.setObjectName(_fromUtf8("chk_box_nlr"))
        self.gridLayout.addWidget(self.chk_box_nlr, 1, 1, 1, 1)
        self.chkbox_dor = QtGui.QCheckBox(self.metrics_grp_box)
        self.chkbox_dor.setObjectName(_fromUtf8("chkbox_dor"))
        self.gridLayout.addWidget(self.chkbox_dor, 2, 0, 1, 1)
        self.verticalLayout.addLayout(self.gridLayout)
        self.formLayout_2.setWidget(0, QtGui.QFormLayout.LabelRole, self.metrics_grp_box)
        self.horizontalLayout = QtGui.QHBoxLayout()
        self.horizontalLayout.setObjectName(_fromUtf8("horizontalLayout"))
        spacerItem = QtGui.QSpacerItem(260, 20, QtGui.QSizePolicy.Expanding, QtGui.QSizePolicy.Minimum)
        self.horizontalLayout.addItem(spacerItem)
        self.btn_ok = QtGui.QPushButton(diag_metric)
        self.btn_ok.setMaximumSize(QtCore.QSize(75, 23))
        self.btn_ok.setObjectName(_fromUtf8("btn_ok"))
        self.horizontalLayout.addWidget(self.btn_ok)
        self.formLayout_2.setLayout(1, QtGui.QFormLayout.LabelRole, self.horizontalLayout)

        self.retranslateUi(diag_metric)
        QtCore.QMetaObject.connectSlotsByName(diag_metric)

    def retranslateUi(self, diag_metric):
        diag_metric.setWindowTitle(QtGui.QApplication.translate("diag_metric", "Diagnostic Metrics", None, QtGui.QApplication.UnicodeUTF8))
        self.metrics_grp_box.setTitle(QtGui.QApplication.translate("diag_metric", "select metrics for analysis", None, QtGui.QApplication.UnicodeUTF8))
        self.chk_box_sens.setText(QtGui.QApplication.translate("diag_metric", "sensitivity", None, QtGui.QApplication.UnicodeUTF8))
        self.chk_box_spec.setText(QtGui.QApplication.translate("diag_metric", "specificity", None, QtGui.QApplication.UnicodeUTF8))
        self.chk_bo_plr.setText(QtGui.QApplication.translate("diag_metric", "positive likelihood ratio", None, QtGui.QApplication.UnicodeUTF8))
        self.chk_box_nlr.setText(QtGui.QApplication.translate("diag_metric", "negative likelihood ratio", None, QtGui.QApplication.UnicodeUTF8))
        self.chkbox_dor.setText(QtGui.QApplication.translate("diag_metric", "diagnostic odds ratio", None, QtGui.QApplication.UnicodeUTF8))
        self.btn_ok.setText(QtGui.QApplication.translate("diag_metric", "next >", None, QtGui.QApplication.UnicodeUTF8))

import icons_rc
