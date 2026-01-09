Class {
	#name : 'CogVMSimulatorLSBCountingStaticLinks',
	#superclass : 'CogVMSimulatorLSB',
	#instVars : [
		'staticSendCounter'
	],
	#category : 'VMMakerTests',
	#package : 'VMMakerTests'
}

{ #category : 'as yet unclassified' }
CogVMSimulatorLSBCountingStaticLinks >> basicInitialize [

	super basicInitialize.
	staticSendCounter := 0
]

{ #category : 'as yet unclassified' }
CogVMSimulatorLSBCountingStaticLinks >> ceStaticSend: a to: b numArgs: c [

	staticSendCounter := staticSendCounter + 1.
	super ceStaticSend: a to: b numArgs: c
]

{ #category : 'accessing' }
CogVMSimulatorLSBCountingStaticLinks >> staticCallLinkCounter [
	
	^ staticSendCounter
]

{ #category : 'accessing' }
CogVMSimulatorLSBCountingStaticLinks >> staticCallLinkCounterReset [
	
	 staticSendCounter := 0.
]
