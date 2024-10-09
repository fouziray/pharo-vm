Class {
	#name : #VMStackToRegisterMappingStaticMessageSendTest,
	#superclass : #VMStackToRegisterMappingCogitTest,
	#category : #'VMMakerTests-JitTests'
}

{ #category : #helpers }
VMStackToRegisterMappingStaticMessageSendTest >> initStack [

	self createBaseFrame.
	
	"Initialize Stack to the correct pointers in the selected page"
	machineSimulator smalltalkStackPointerRegisterValue: interpreter stackPointer.
	machineSimulator framePointerRegisterValue: interpreter framePointer.
	machineSimulator baseRegisterValue: cogit varBaseAddress.

	cogit setCStackPointer: interpreter rumpCStackAddress.
	cogit setCFramePointer: interpreter rumpCStackAddress.

]

{ #category : #running }
VMStackToRegisterMappingStaticMessageSendTest >> setUpTrampolines [

	super setUpTrampolines.
	
	cogit methodAbortTrampolines at: 0 put: cogit ceMethodAbortTrampoline.
	cogit methodAbortTrampolines at: 1 put: cogit ceMethodAbortTrampoline.
	cogit methodAbortTrampolines at: 2 put: cogit ceMethodAbortTrampoline.
	cogit methodAbortTrampolines at: 3 put: cogit ceMethodAbortTrampoline.
	
	cogit picMissTrampolines at: 0 put: cogit ceCPICMissTrampoline.
	cogit picMissTrampolines at: 1 put: cogit ceCPICMissTrampoline.
	cogit picMissTrampolines at: 2 put: cogit ceCPICMissTrampoline.
	cogit picMissTrampolines at: 3 put: cogit ceCPICMissTrampoline.

	cogit picAbortTrampolines at: 0 put: cogit cePICAbortTrampoline.
	cogit picAbortTrampolines at: 1 put: cogit cePICAbortTrampoline.
	cogit picAbortTrampolines at: 2 put: cogit cePICAbortTrampoline.
	cogit picAbortTrampolines at: 3 put: cogit cePICAbortTrampoline.
	
	cogit generateStaticSendTrampoline.
		
	cogit ceStoreCheckTrampoline: (self compileTrampoline: [ cogit RetN: 0 ] named:#ceStoreCheckTrampoline).
	cogit objectRepresentation setAllStoreTrampolinesWith: (self compileTrampoline: [ cogit RetN: 0 ] named: #ceStoreTrampoline).
]

{ #category : #'tests - sends static' }
VMStackToRegisterMappingStaticMessageSendTest >> testStaticSendOfCeStaticMethod [

	| selector calledCompiledMethod staticCallerCompiledMethod staticCallerCogMethod |

	self setUpTrampolines.
	cogit computeEntryOffsets.

	calledCompiledMethod := self createMethodOopFromHostMethod: (Object >> #yourself).
	
	selector := self newOldSpaceObjectWithSlots: 0.
	
	staticCallerCompiledMethod := methodBuilder newMethod
			 literalAt: 0 put: (memory integerObjectOf: 13);
			 literalAt: 1 put: calledCompiledMethod;
			 literalAt: 2 put: selector;
			 literalAt: 3 put: memory nilObject;
			 bytecodes: #[32 "PushLiteral 1" 
				246 1 "Static Send literal at 2"
				92 "Return top"];
			 buildMethod.

	staticCallerCogMethod := cogit cog: staticCallerCompiledMethod selector: memory nilObject.

	self createFramefulCallFrom: callerAddress.
	
	"Push receiver, arg, then send"
	self pushAddress: memory falseObject.
	interpreter push: callerAddress .
	interpreter ceStaticSendInterpreted: calledCompiledMethod.
	self assert: machineSimulator pc equals: cogit staticSendTrampoline.
	self assert: machineSimulator classRegisterValue equals: calledCompiledMethod 
]

{ #category : #'tests - sends static' }
VMStackToRegisterMappingStaticMessageSendTest >> testStaticSendOfCoggedMethodCallMethodDirectly [

	| selector calledCompiledMethod calledCogMethod staticCallerCompiledMethod staticCallerCogMethod |

	self setUpTrampolines.
	cogit computeEntryOffsets.

	calledCompiledMethod := self createMethodOopFromHostMethod: (Object >> #yourself).
	calledCogMethod := cogit cog: calledCompiledMethod selector: memory nilObject.
	
	selector := self newOldSpaceObjectWithSlots: 0.
	
	staticCallerCompiledMethod := methodBuilder newMethod
			 literalAt: 0 put: (memory integerObjectOf: 13);
			 literalAt: 1 put: calledCompiledMethod;
			 literalAt: 2 put: selector;
			 literalAt: 3 put: memory nilObject;
			 bytecodes: #[32 "PushLiteral 1" 
				246 1 "Static Send literal at 2"
				92 "Return top"];
			 buildMethod.

	staticCallerCogMethod := cogit cog: staticCallerCompiledMethod selector: memory nilObject.

	self createFramefulCallFrom: callerAddress.
	
	"Push receiver, arg, then send"
	self pushAddress: memory falseObject.

	self 
		runFrom: (staticCallerCogMethod address + cogit noCheckEntryOffset) 
		until: calledCogMethod address + cogit noCheckEntryOffset. 

	self assert: machineSimulator pc equals: calledCogMethod address + cogit noCheckEntryOffset
]

{ #category : #'tests - sends static' }
VMStackToRegisterMappingStaticMessageSendTest >> testStaticSendOfNonCoggedMethodActivatesCorrectMethod [

	| selector calledCompiledMethod staticCallerCompiledMethod staticCallerCogMethod |

	self setUpTrampolines.
	cogit generateEnilopmarts.
	cogit computeEntryOffsets.

	self initStack.	

	calledCompiledMethod := self createMethodOopFromHostMethod: (Object >> #yourself).
	
	selector := self newOldSpaceObjectWithSlots: 0.
	
	staticCallerCompiledMethod := methodBuilder newMethod
			 literalAt: 0 put: (memory integerObjectOf: 13);
			 literalAt: 1 put: calledCompiledMethod;
			 literalAt: 2 put: selector;
			 literalAt: 3 put: memory nilObject;
			 bytecodes: #[32 "PushLiteral 1" 
				246 1 "Static Send literal at 2"
				92 "Return top"];
			 buildMethod.

	staticCallerCogMethod := cogit cog: staticCallerCompiledMethod selector: memory nilObject.


	self createFramefulCallFrom: callerAddress.
	
	"Push receiver, arg, then send"
	self pushAddress: memory falseObject.

	self 
		runFrom: (staticCallerCogMethod address + cogit noCheckEntryOffset)  
		until: callerAddress.  
	self assert: machineSimulator pc equals: cogit staticSendTrampoline
]

{ #category : #'tests - sends static' }
VMStackToRegisterMappingStaticMessageSendTest >> testStaticSendOfNonCoggedMethodCallsTrampoline [

	| selector calledCompiledMethod staticCallerCompiledMethod staticCallerCogMethod |

	self setUpTrampolines.
	cogit computeEntryOffsets.

	calledCompiledMethod := self createMethodOopFromHostMethod: (Object >> #yourself).
	
	selector := self newOldSpaceObjectWithSlots: 0.
	
	staticCallerCompiledMethod := methodBuilder newMethod
			 literalAt: 0 put: (memory integerObjectOf: 13);
			 literalAt: 1 put: calledCompiledMethod;
			 literalAt: 2 put: selector;
			 literalAt: 3 put: memory nilObject;
			 bytecodes: #[32 "PushLiteral 1" 
				246 1 "Static Send literal at 2"
				92 "Return top"];
			 buildMethod.

	staticCallerCogMethod := cogit cog: staticCallerCompiledMethod selector: memory nilObject.

	self createFramefulCallFrom: callerAddress.
	
	"Push receiver, arg, then send"
	self pushAddress: memory falseObject.
	
	self 
		runFrom: (staticCallerCogMethod address + cogit noCheckEntryOffset) 
		until: cogit staticSendTrampoline. 
	self assert: machineSimulator pc equals: cogit staticSendTrampoline.
	self assert: machineSimulator classRegisterValue equals: calledCompiledMethod 
]
