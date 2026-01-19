Class {
	#name : 'VMStackToRegisterMappingStaticMessageSendTest',
	#superclass : 'VMStackToRegisterMappingCogitTest',
	#category : 'VMMakerTests',
	#package : 'VMMakerTests'
}

{ #category : 'as yet unclassified' }
VMStackToRegisterMappingStaticMessageSendTest >> callMySelf [
	self _VMStackToRegisterMappingStaticMessageSendTest_myYourself 
]

{ #category : 'patching' }
VMStackToRegisterMappingStaticMessageSendTest >> getInstructionsStartingFrom: start to: end [

	^ machineSimulator disassembler
		  printImmediatesInHexa;
		  useAlternatePrinterVariant;
		  disassembleNext: 150
		  instructionsIn:
			  (cogit objectMemory memoryManager copyFrom: start to: end)
		  startAddress: start
		  pc: machineSimulator instructionPointerRegisterValue
]

{ #category : 'helpers' }
VMStackToRegisterMappingStaticMessageSendTest >> initStack [

	self createBaseFrame.
	
	"Initialize Stack to the correct pointers in the selected page"
	machineSimulator smalltalkStackPointerRegisterValue: interpreter stackPointer.
	machineSimulator framePointerRegisterValue: interpreter framePointer.
	machineSimulator baseRegisterValue: cogit varBaseAddress.

	cogit setCStackPointer: interpreter rumpCStackAddress.
	cogit setCFramePointer: interpreter rumpCStackAddress.

]

{ #category : 'tests' }
VMStackToRegisterMappingStaticMessageSendTest >> installSelector: aSelectorOop method: aMethodOop inMethodDictionary: aMethodDictionary [
	
	| anArrayOfMethods |
	anArrayOfMethods := memory fetchPointer: MethodArrayIndex ofObject: aMethodDictionary.
	memory
		storePointer: (memory methodDictionaryHash: aSelectorOop mask: 11) + 2
		ofObject: aMethodDictionary
		withValue: aSelectorOop.
	memory
		storePointer: (memory methodDictionaryHash: aSelectorOop mask: 11)
		ofObject: anArrayOfMethods
		withValue: aMethodOop
]

{ #category : 'as yet unclassified' }
VMStackToRegisterMappingStaticMessageSendTest >> interpreterClass [

	^ CogVMSimulatorLSBCountingStaticLinks
]

{ #category : 'as yet unclassified' }
VMStackToRegisterMappingStaticMessageSendTest >> myYourself [

	| x |
	x := self.
	^ x
]

{ #category : 'as yet unclassified' }
VMStackToRegisterMappingStaticMessageSendTest >> setUp [ 

	super setUp.

	self setUpTrampolines.
	cogit generateEnilopmarts.
	
	cogit methodZoneBase: cogit methodZone freeStart.

	cogit computeEntryOffsets.

	self initStack.	

]

{ #category : 'initialization' }
VMStackToRegisterMappingStaticMessageSendTest >> setUpMethodDictionaryIn: aClass [
	"2 instances variables the array of methods and the tally
	and 12 entries to put elemetns of the collection"
	
	| aMethodDictionary anArrayOfMethods |
	aMethodDictionary := self
		newObjectWithSlots: 2 + 12
		format: MethodDictionary instSpec
		classIndex: memory arrayClassIndexPun.
	anArrayOfMethods := self
		newObjectWithSlots: 12
		format: Array instSpec
		classIndex: memory arrayClassIndexPun.
	memory
		storePointer: MethodDictionaryIndex
		ofObject: aClass
		withValue: aMethodDictionary.
	memory
		storePointer: MethodArrayIndex
		ofObject: aMethodDictionary
		withValue: anArrayOfMethods.
		
	

]

{ #category : 'as yet unclassified' }
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

	cogit ceStoreCheckTrampoline: (self
			 compileTrampoline: [ cogit RetN: 0 ]
			 named: #ceStoreCheckTrampoline).
	cogit objectRepresentation setAllStoreTrampolinesWith:
		(self compileTrampoline: [ cogit RetN: 0 ] named: #ceStoreTrampoline)
]

{ #category : 'beforeCall' }
VMStackToRegisterMappingStaticMessageSendTest >> testInstructionLoadBeforeStaticSend [

	| selector calledCompiledMethod staticCallerCompiledMethod staticCallerCogMethod builder staticCallTargetCogMethod instructionsBefore |
	calledCompiledMethod := self createMethodOopFromHostMethod:
		                        self class >> #myYourself.

	selector := self newOldSpaceObjectWithSlots: 0.


	cogit ceSmallActiveContextInFullBlockTrampoline: (self compile: [
			 cogit.
			 cogit RetN: 0 ]).

	staticCallerCompiledMethod := methodBuilder newMethod
		                              literalAt: 0
		                              put: (memory integerObjectOf: 13);
		                              literalAt: 1
		                              put: calledCompiledMethod;
		                              literalAt: 2 put: selector;
		                              literalAt: 3 put: memory nilObject;
		                              bytecodes: #[ 32 246 1 92 ];
		                              buildMethod. "PushLiteral 1" "Static Send literal at 2" "Return top"

	cogit generateSendTrampolines.
	staticCallerCogMethod := cogit
		                         cog: staticCallerCompiledMethod
		                         selector: memory nilObject.
	staticCallTargetCogMethod := cogit
		                             cog: calledCompiledMethod
		                             selector: memory nilObject.

	builder := self machineCodeFrameBuilder.
	builder returnAddress: callerAddress.
	builder receiver: memory falseObject.
	builder method: staticCallerCogMethod.
	builder buildFrame.

	interpreter stackPointer:
		machineSimulator smalltalkStackPointerRegisterValue.
	interpreter framePointer: machineSimulator framePointerRegisterValue.

	self
		runFrom: staticCallerCogMethod address + cogit noCheckEntryOffset
		until: staticCallTargetCogMethod address
			+ staticCallTargetCogMethod stackCheckOffset.


	instructionsBefore := self
		                      getInstructionsStartingFrom:
		                      staticCallerCogMethod address
		                      + cogit noCheckEntryOffset
		                      to: staticCallTargetCogMethod address
			                      + staticCallTargetCogMethod stackCheckOffset.

	self
		assert: (instructionsBefore at: 22) assemblyCodeString
		equals: 'ldr	x1, #40'. " x1 here is the tempReg"
	self assert:
		(memory isOopCompiledMethod: (machineSimulator memory longAt:
				  (instructionsBefore at: 22) address + 40)).
	self
		assert: (machineSimulator memory longAt:
				 (instructionsBefore at: 22) address + 40)
		equals: calledCompiledMethod.
	self
		assert: machineSimulator instructionPointerRegisterValue
		equals: staticCallTargetCogMethod address
			+ staticCallTargetCogMethod stackCheckOffset
]

{ #category : 'beforeCall' }
VMStackToRegisterMappingStaticMessageSendTest >> testNormalSendExpectedInstructionBeforeCall [

	| selector calledCompiledMethod calledCompiledMethod1 callerCogMethod builder callTargetCogMethod instructionsBefore receiverClass aMethodDictionary dereferenceRoutine |
	calledCompiledMethod1 := self createMethodOopFromHostMethod:
		                        self class >>#myYourself.
	
	selector := #myYourself forMemory: memory inMethod: nil. 
	
		callTargetCogMethod :=methodBuilder newMethod
		                              literalAt: 0
		                              put: (memory integerObjectOf: 13);
		                              literalAt: 1
		                              put: selector ;
		                              bytecodes: #[ 32 129 92 ];
		          	                  buildMethod. 
	receiverClass := self setSmallIntegerClassIntoClassTable.
	self setUpMethodDictionaryIn: receiverClass.

	aMethodDictionary := memory
		                     fetchPointer: MethodDictionaryIndex
		                     ofObject: receiverClass.
interpreter methodDictLinearSearchLimit: 100.
	self
		installSelector: selector
		method: calledCompiledMethod1
		inMethodDictionary: aMethodDictionary.

	


	
	dereferenceRoutine := self compile: [ 
		cogit MoveCq: selector R: ClassReg .
		cogit RetN: 0 ].
	cogit methodZoneBase: cogit methodZone zoneFree .
	
	cogit ceDereferenceSelectorIndex: dereferenceRoutine.
cogit generateSendTrampolines.


	callerCogMethod := cogit
		                         cog: callTargetCogMethod
		                         selector: memory nilObject.
	calledCompiledMethod :=  cogit
		                             cog: calledCompiledMethod1
		                             selector: selector.

	builder := self machineCodeFrameBuilder.
	builder returnAddress: callerAddress.
	builder receiver: memory falseObject.
	builder method: callerCogMethod.
	builder buildFrame.

	interpreter stackPointer:
		machineSimulator smalltalkStackPointerRegisterValue.
	interpreter framePointer: machineSimulator framePointerRegisterValue.


	self
		runFrom: callerCogMethod address + cogit noCheckEntryOffset
		until: calledCompiledMethod address
			+ calledCompiledMethod stackCheckOffset.


	instructionsBefore := self
		                      getInstructionsStartingFrom: callerCogMethod address
		                      + cogit noCheckEntryOffset
		                      to:  calledCompiledMethod address +  calledCompiledMethod stackCheckOffset  .
self assert: (instructionsBefore at: 14) assemblyCodeString equals: 'ldr	x22, #32'. " x1 here is the Class Register"
	self assert: (memory longAt: 	(instructionsBefore at: (14 )) address + 32) equals: 1.
	self
		assert: machineSimulator instructionPointerRegisterValue
		equals: calledCompiledMethod address
			+ calledCompiledMethod stackCheckOffset.
]

{ #category : 'beforeCall' }
VMStackToRegisterMappingStaticMessageSendTest >> testNormalSendExpectedInstructionBeforeCall2 [

	| selector calledCompiledMethod callerCogMethod builder callTargetCogMethod instructionsBefore |
	calledCompiledMethod := self createMethodOopFromHostMethod:
		                        self class >> #myYourself.

	selector := #myYourself forMemory: memory inMethod: nil. 

	self createFramefulCallFrom: callerAddress.
self pushAddress: methodReceiver .
	self pushAddress: memory trueObject.

	self assert: machineSimulator classRegisterValue equals: selector.
	cogit generateSendTrampolines.

	sendAddress := self compile: [ cogit genSendLiteralSelector0ArgsBytecode ].

		interpreter stackPointer:
		machineSimulator smalltalkStackPointerRegisterValue.
	interpreter framePointer: machineSimulator framePointerRegisterValue.


	instructionsBefore := self
		                      getInstructionsStartingFrom:
		                      callerCogMethod address
		                      + cogit noCheckEntryOffset
		                      to: callTargetCogMethod address
			                      + callTargetCogMethod stackCheckOffset.
	
	self runFrom: sendAddress until: sendTrampolineAddress.
	self assert: (instructionsBefore at: 22) assemblyCodeString equals: 'ldr	x1, #40'. " x1 here is the tempReg"
	self
		assert: machineSimulator instructionPointerRegisterValue
		equals: callTargetCogMethod address
			+ callTargetCogMethod stackCheckOffset.
]

{ #category : 'beforeCall' }
VMStackToRegisterMappingStaticMessageSendTest >> testNormalSendExpectedInstructionBeforeCall3 [

	| selector calledCompiledMethod calledCompiledMethod1 callerCogMethod builder callTargetCogMethod instructionsBefore |
	calledCompiledMethod := self createMethodOopFromHostMethod:
		                        self class >> #callMySelf .
	calledCompiledMethod1 := self createMethodOopFromHostMethod:
		                        self class >> #myYourself .
	
		
	


	cogit generateSendTrampolines.
	callTargetCogMethod := cogit
		                         cog: calledCompiledMethod1
		                         selector: memory nilObject.
	
	callerCogMethod := cogit
		                         cog: calledCompiledMethod
		                         selector: memory nilObject.
builder := self machineCodeFrameBuilder.
	builder returnAddress: callerAddress.
	builder receiver: memory falseObject.
	builder method: callerCogMethod.
	builder buildFrame.
	interpreter stackPointer:
		machineSimulator smalltalkStackPointerRegisterValue.
	interpreter framePointer: machineSimulator framePointerRegisterValue.

	self
		runFrom: callerCogMethod address + cogit noCheckEntryOffset
		until: callTargetCogMethod address
			+ callTargetCogMethod stackCheckOffset.


	instructionsBefore := self
		                      getInstructionsStartingFrom:
		                      callerCogMethod address
		                      + cogit noCheckEntryOffset
		                      to: callTargetCogMethod address
			                      + callTargetCogMethod stackCheckOffset.
self assert: (instructionsBefore at: 22) assemblyCodeString equals: 'ldr	x1, #40'. " x1 here is the tempReg"
	self
		assert: machineSimulator instructionPointerRegisterValue
		equals: callTargetCogMethod address
			+ callTargetCogMethod stackCheckOffset.
]

{ #category : 'beforeCall' }
VMStackToRegisterMappingStaticMessageSendTest >> testNormalSendExpectedInstructionBeforeCallCOpiedFromExistingBytecode [

	| selector calledCompiledMethod calledCompiledMethod1 callerCogMethod builder callTargetCogMethod instructionsBefore |
	calledCompiledMethod1 := self createMethodOopFromHostMethod:
		                        self class >> #myYourself.

	selector := #myYourself forMemory: memory inMethod: nil. 
		callTargetCogMethod :=methodBuilder newMethod
		                              literalAt: 0
		                              put: (memory integerObjectOf: 13);
		                              literalAt: 1
		                              put:(memory newExternalAddressWithValue: selector)"memory nilObject"  ;
		                              bytecodes: #[ 76 128 216 88 ];
		          	                  buildMethod. 
		interpreter printOop: callTargetCogMethod.


	cogit generateSendTrampolines.
	calledCompiledMethod :=  cogit
		                             cog: calledCompiledMethod1
		                             selector: selector.
	callerCogMethod := cogit
		                         cog: callTargetCogMethod
		                         selector: memory nilObject.

	builder := self machineCodeFrameBuilder.
	builder returnAddress: callerAddress.
	builder receiver: memory falseObject.
	builder method: callerCogMethod.
	builder buildFrame.

	interpreter stackPointer:
		machineSimulator smalltalkStackPointerRegisterValue.
	interpreter framePointer: machineSimulator framePointerRegisterValue.

	self
		runFrom: callerCogMethod address + cogit noCheckEntryOffset
		until: calledCompiledMethod address
			+ calledCompiledMethod stackCheckOffset.


	instructionsBefore := self
		                      getInstructionsStartingFrom:
		                      callerCogMethod address
		                      + cogit noCheckEntryOffset
		                      to: callTargetCogMethod address
			                      + callTargetCogMethod stackCheckOffset.
self assert: (instructionsBefore at: 22) assemblyCodeString equals: 'ldr	x1, #40'. " x1 here is the tempReg"
	self
		assert: machineSimulator instructionPointerRegisterValue
		equals: callTargetCogMethod address
			+ callTargetCogMethod stackCheckOffset.
]

{ #category : 'beforeCall' }
VMStackToRegisterMappingStaticMessageSendTest >> testNormalSendExpectedInstructionBeforeSecondCall [

	| selector calledCompiledMethod calledCompiledMethod1 callerCogMethod builder callTargetCogMethod instructionsBefore receiverClass aMethodDictionary dereferenceRoutine  |
	calledCompiledMethod1 := self createMethodOopFromHostMethod:
		                        self class >>#myYourself.
	
	selector := #myYourself forMemory: memory inMethod: nil. 
	
		callTargetCogMethod :=methodBuilder newMethod
		                              literalAt: 0
		                              put: (memory integerObjectOf: 13);
		                              literalAt: 1
		                              put: selector ;
		                              bytecodes: #[ 32 129 92 ];
		          	                  buildMethod. 
	receiverClass := self setSmallIntegerClassIntoClassTable.
	self setUpMethodDictionaryIn: receiverClass.

	aMethodDictionary := memory
		                     fetchPointer: MethodDictionaryIndex
		                     ofObject: receiverClass.
interpreter methodDictLinearSearchLimit: 100.
	self
		installSelector: selector
		method: calledCompiledMethod1
		inMethodDictionary: aMethodDictionary.

	


	
	dereferenceRoutine := self compile: [ 
		cogit MoveCq: selector R: ClassReg .
		cogit RetN: 0 ].
	cogit methodZoneBase: cogit methodZone zoneFree .
	
	cogit ceDereferenceSelectorIndex: dereferenceRoutine.
cogit generateSendTrampolines.


	callerCogMethod := cogit
		                         cog: callTargetCogMethod
		                         selector: memory nilObject.
	calledCompiledMethod :=  cogit
		                             cog: calledCompiledMethod1
		                             selector: selector.

	builder := self machineCodeFrameBuilder.
	builder returnAddress: callerAddress.
	builder receiver: memory falseObject.
	builder method: callerCogMethod.
	builder buildFrame.

	interpreter stackPointer:
		machineSimulator smalltalkStackPointerRegisterValue.
	interpreter framePointer: machineSimulator framePointerRegisterValue.

instructionsBefore := self
		                      getInstructionsStartingFrom: callerCogMethod address
		                      + cogit noCheckEntryOffset
		                      to:  calledCompiledMethod address +  calledCompiledMethod stackCheckOffset  .
		
	self assert: (instructionsBefore at: 15) assemblyCodeString equals: 'bl', Character tab asString,'#', (   (cogit instVarNamed: 'ordinarySendTrampolines') first -  (instructionsBefore at: 15) address)  asString.
	self
		runFrom: callerCogMethod address + cogit noCheckEntryOffset
		until: calledCompiledMethod address
			+ calledCompiledMethod stackCheckOffset.


	instructionsBefore := self
		                      getInstructionsStartingFrom: callerCogMethod address
		                      + cogit noCheckEntryOffset
		                      to:  calledCompiledMethod address +  calledCompiledMethod stackCheckOffset  .
self assert: (instructionsBefore at: 15) assemblyCodeString equals: 'bl', Character tab asString,'#', (  calledCompiledMethod  address+ cogit entryOffset -  (instructionsBefore at: 15) address)  asString.
self assert: (instructionsBefore at: 14) assemblyCodeString equals: 'ldr	x22, #32'. " x1 here is the Class Register"
	self assert: (memory longAt: 	(instructionsBefore at: (14 )) address + 32) equals: 1.
	self
		assert: machineSimulator instructionPointerRegisterValue
		equals: calledCompiledMethod address
			+ calledCompiledMethod stackCheckOffset.
 
	self assert: (instructionsBefore at: 15) assemblyCodeString equals: 'bl', Character tab asString,'#100'.
	self
		runFrom: callerCogMethod address + cogit noCheckEntryOffset
		until: calledCompiledMethod address
			+ calledCompiledMethod stackCheckOffset.
	self
		runFrom: callerCogMethod address + cogit noCheckEntryOffset
		until: calledCompiledMethod address
			+ calledCompiledMethod stackCheckOffset.
							
	instructionsBefore := self
		                      getInstructionsStartingFrom: callerCogMethod address
		                      + cogit noCheckEntryOffset
		                      to:  calledCompiledMethod address +  calledCompiledMethod stackCheckOffset  .
		
]

{ #category : 'as yet unclassified' }
VMStackToRegisterMappingStaticMessageSendTest >> testStaticSendExecutesLinkedCall [

	| selector calledCompiledMethod staticCallerCompiledMethod staticCallerCogMethod builder staticCallTargetCogMethod |
	calledCompiledMethod := self createMethodOopFromHostMethod:
		                        self class >> #myYourself.

	selector := self newOldSpaceObjectWithSlots: 0.

	staticCallerCompiledMethod := methodBuilder newMethod
		                              literalAt: 0
		                              put: (memory integerObjectOf: 13);
		                              literalAt: 1
		                              put: calledCompiledMethod;
		                              literalAt: 2 put: selector;
		                              literalAt: 3 put: memory nilObject;
		                              bytecodes: #[ 32 246 1 92 ];
		                              buildMethod. "PushLiteral 1" "Static Send literal at 2" "Return top"

	cogit generateSendTrampolines.
	staticCallerCogMethod := cogit
		                         cog: staticCallerCompiledMethod
		                         selector: memory nilObject.
	staticCallTargetCogMethod := cogit
		                             cog: calledCompiledMethod
		                             selector: memory nilObject.


	builder := self machineCodeFrameBuilder.
	builder returnAddress: callerAddress.
	builder receiver: memory falseObject.
	builder method: staticCallerCogMethod.
	builder buildFrame.

	interpreter stackPointer:
		machineSimulator smalltalkStackPointerRegisterValue.
	interpreter framePointer: machineSimulator framePointerRegisterValue.

	"Push receiver, arg, then send"
	"interpreter push: (memory integerObjectOf: 13)."
	"	interpreter push: 16r320000460."

	"machineSimulator smalltalkStackPointerRegisterValue:
		interpreter stackPointer."



	self
		runFrom: staticCallerCogMethod address + cogit noCheckEntryOffset
		until: staticCallTargetCogMethod address
			+ staticCallTargetCogMethod stackCheckOffset.

	self
		runFrom: staticCallerCogMethod address + cogit noCheckEntryOffset
		until: staticCallTargetCogMethod address
			+ staticCallTargetCogMethod stackCheckOffset.

	"self openMachineDebuggerAt: staticCallerCogMethod address + cogit noCheckEntryOffset"

	self
		assert: machineSimulator instructionPointerRegisterValue
		equals: staticCallTargetCogMethod address
			+ staticCallTargetCogMethod stackCheckOffset.
	self assert: interpreter staticCallLinkCounter equals: 1
]

{ #category : 'as yet unclassified' }
VMStackToRegisterMappingStaticMessageSendTest >> testStaticSendExecutesLinkedCall2 [

	| selector calledCompiledMethod staticCallerCompiledMethod staticCallerCogMethod builder staticCallTargetCogMethod |
	calledCompiledMethod := self createMethodOopFromHostMethod:
		                        self class >> #myYourself.

	selector := self newOldSpaceObjectWithSlots: 0.

	staticCallerCompiledMethod := methodBuilder newMethod
		                              literalAt: 0
		                              put: (memory integerObjectOf: 13);
		                              literalAt: 1
		                              put: calledCompiledMethod;
		                              literalAt: 2 put: selector;
		                              literalAt: 3 put: memory nilObject;
		                              bytecodes: #[ 32 246 1 92 ];
		                              buildMethod. "PushLiteral 1" "Static Send literal at 2" "Return top"

	cogit generateSendTrampolines.
	staticCallerCogMethod := cogit
		                         cog: staticCallerCompiledMethod
		                         selector: memory nilObject.
	staticCallTargetCogMethod := cogit
		                             cog: calledCompiledMethod
		                             selector: memory nilObject.


	builder := self machineCodeFrameBuilder.
	builder returnAddress: callerAddress.
	builder receiver: memory falseObject.
	builder method: staticCallerCogMethod.
	builder buildFrame.

	interpreter stackPointer:
		machineSimulator smalltalkStackPointerRegisterValue.
	interpreter framePointer: machineSimulator framePointerRegisterValue.

	"Push receiver, arg, then send"
	"interpreter push: (memory integerObjectOf: 13)."
	"	interpreter push: 16r320000460."

	"machineSimulator smalltalkStackPointerRegisterValue:
		interpreter stackPointer."



	self
		runFrom: staticCallerCogMethod address + cogit noCheckEntryOffset
		until: staticCallTargetCogMethod address
			+ staticCallTargetCogMethod stackCheckOffset.

	self
		runFrom: staticCallerCogMethod address + cogit noCheckEntryOffset
		until: staticCallTargetCogMethod address
			+ staticCallTargetCogMethod stackCheckOffset.

	self
		runFrom: staticCallerCogMethod address + cogit noCheckEntryOffset
		until: staticCallTargetCogMethod address
			+ staticCallTargetCogMethod stackCheckOffset.
	"self openMachineDebuggerAt: staticCallerCogMethod address + cogit noCheckEntryOffset"

	self
		assert: machineSimulator instructionPointerRegisterValue
		equals: staticCallTargetCogMethod address
			+ staticCallTargetCogMethod stackCheckOffset.
	self assert: interpreter staticCallLinkCounter equals: 1
]

{ #category : 'as yet unclassified' }
VMStackToRegisterMappingStaticMessageSendTest >> testStaticSendExecutesUnlinkedCall [

	| selector calledCompiledMethod staticCallerCompiledMethod staticCallerCogMethod builder staticCallTargetCogMethod |
	calledCompiledMethod := self createMethodOopFromHostMethod:
		                        self class >> #myYourself.

	selector := self newOldSpaceObjectWithSlots: 0.

	staticCallerCompiledMethod := methodBuilder newMethod
		                              literalAt: 0
		                              put: (memory integerObjectOf: 13);
		                              literalAt: 1
		                              put: calledCompiledMethod;
		                              literalAt: 2 put: selector;
		                              literalAt: 3 put: memory nilObject;
		                              bytecodes: #[ 32 246 1 92 ];
		                              buildMethod. "PushLiteral 1" "Static Send literal at 2" "Return top"

	cogit generateSendTrampolines.
	staticCallerCogMethod := cogit
		                         cog: staticCallerCompiledMethod
		                         selector: memory nilObject.
	staticCallTargetCogMethod := cogit
		                             cog: calledCompiledMethod
		                             selector: memory nilObject.


	builder := self machineCodeFrameBuilder.
	builder returnAddress: callerAddress.
	builder receiver: memory falseObject.
	builder method: staticCallerCogMethod.
	builder buildFrame.

	interpreter stackPointer:
		machineSimulator smalltalkStackPointerRegisterValue.
	interpreter framePointer: machineSimulator framePointerRegisterValue.

	"Push receiver, arg, then send"
	"interpreter push: (memory integerObjectOf: 13)."
	"	interpreter push: 16r320000460."

	"machineSimulator smalltalkStackPointerRegisterValue:
		interpreter stackPointer."



	self
		runFrom: staticCallerCogMethod address + cogit noCheckEntryOffset
		until: staticCallTargetCogMethod address
			+ staticCallTargetCogMethod stackCheckOffset.

	"Here we remove the method from compiled code space and see if the call site is linked back to its original state"

	"self openMachineDebuggerAt: staticCallerCogMethod address.
	"
	self createBaseFrame. 
	interpreter commenceCogCompiledCodeCompaction.
	cogit freeMethod: staticCallerCogMethod address.
	
	self
		runFrom: staticCallerCogMethod address + cogit noCheckEntryOffset
		until: staticCallTargetCogMethod address
			+ staticCallTargetCogMethod stackCheckOffset.

	"self openMachineDebuggerAt: staticCallerCogMethod address + cogit noCheckEntryOffset"

	self
		assert: machineSimulator instructionPointerRegisterValue
		equals: staticCallTargetCogMethod address
			+ staticCallTargetCogMethod stackCheckOffset.
	self assert: interpreter staticCallLinkCounter equals: 2
]

{ #category : 'as yet unclassified' }
VMStackToRegisterMappingStaticMessageSendTest >> testStaticSendExecutesUnlinkedCall2 [

	| selector calledCompiledMethod staticCallerCompiledMethod staticCallerCogMethod builder staticCallTargetCogMethod instructionsUnlinked instructionsLinked instructionsAfterFree instructionsBefore instructionsAfter |
	calledCompiledMethod := self createMethodOopFromHostMethod:
		                        self class >> #myYourself.

	selector := self newOldSpaceObjectWithSlots: 0.

	staticCallerCompiledMethod := methodBuilder newMethod
		                              literalAt: 0
		                              put: (memory integerObjectOf: 13);
		                              literalAt: 1
		                              put: calledCompiledMethod;
		                              literalAt: 2 put: selector;
		                              literalAt: 3 put: memory nilObject;
		                              bytecodes: #[ 32 246 1 92 ];
		                              buildMethod. "PushLiteral 1" "Static Send literal at 2" "Return top"

	cogit generateSendTrampolines.
	staticCallerCogMethod := cogit
		                         cog: staticCallerCompiledMethod
		                         selector: memory nilObject.
	staticCallTargetCogMethod := cogit
		                             cog: calledCompiledMethod
		                             selector: memory nilObject.
	
	

	builder := self machineCodeFrameBuilder.
	builder returnAddress: callerAddress.
	builder receiver: memory falseObject.
	builder method: staticCallerCogMethod.
	builder buildFrame.

	interpreter stackPointer:
		machineSimulator smalltalkStackPointerRegisterValue.
	interpreter framePointer: machineSimulator framePointerRegisterValue.

	"Push receiver, arg, then send"
	"interpreter push: (memory integerObjectOf: 13)."
	"	interpreter push: 16r320000460."

	"machineSimulator smalltalkStackPointerRegisterValue:
		interpreter stackPointer."


instructionsUnlinked := self
		                      getInstructionsStartingFrom:
		                      staticCallerCogMethod address
		                      + cogit noCheckEntryOffset
		                      to: staticCallTargetCogMethod address
			                      + staticCallTargetCogMethod stackCheckOffset.
	self
		runFrom: staticCallerCogMethod address + cogit noCheckEntryOffset
		until: staticCallTargetCogMethod address
			+ staticCallTargetCogMethod stackCheckOffset.

instructionsLinked := self
		                      getInstructionsStartingFrom:
		                      staticCallerCogMethod address
		                      + cogit noCheckEntryOffset
		                      to: staticCallTargetCogMethod address
			                      + staticCallTargetCogMethod stackCheckOffset.	
self assert: interpreter staticCallLinkCounter equals: 1.

	
	"Here we remove the method from compiled code space and see if the call site is linked back to its original state"

	self assert: (cogit coInterpreter methodHasCogMethod: staticCallTargetCogMethod  methodObject ).
	"cogit freeMethod: staticCallTargetCogMethod."
	self halt.
	cogit unlinkIfLinkedSend: 7 pc: nil to: staticCallerCogMethod address.
	interpreter staticCallLinkCounterReset.
	self deny: (cogit coInterpreter methodHasCogMethod: staticCallTargetCogMethod  methodObject ).
	instructionsAfterFree := self
		                     getInstructionsStartingFrom:
		                     staticCallerCogMethod address
		                     + cogit noCheckEntryOffset
		                     to: staticCallTargetCogMethod address
			                     + staticCallTargetCogMethod stackCheckOffset.
			1 halt.
self
		runFrom: staticCallerCogMethod address + cogit noCheckEntryOffset
		until: staticCallTargetCogMethod address
			+ staticCallTargetCogMethod stackCheckOffset. 

self
		runFrom: staticCallerCogMethod address + cogit noCheckEntryOffset
		until: staticCallTargetCogMethod address
			+ staticCallTargetCogMethod stackCheckOffset.
	"self openMachineDebuggerAt: staticCallerCogMethod address + cogit noCheckEntryOffset"

	self
		assert: machineSimulator instructionPointerRegisterValue
		equals: staticCallTargetCogMethod address
			+ staticCallTargetCogMethod stackCheckOffset.
	self assert: interpreter staticCallLinkCounter equals: 1.
	

	self
		runFrom: staticCallerCogMethod address + cogit noCheckEntryOffset
		until: staticCallTargetCogMethod address
			+ staticCallTargetCogMethod stackCheckOffset.

	

	self
		assert: (instructionsBefore collect: #asString)
		equals: (instructionsAfter collect: #asString).
]

{ #category : 'as yet unclassified' }
VMStackToRegisterMappingStaticMessageSendTest >> testStaticSendExecutesUnlinkedCallLinkedWithTwoDifferentMSGSends [

	| selector calledCompiledMethod staticCallerCompiledMethod staticCallerCogMethod builder staticCallTargetCogMethod instructionsUnlinked instructionsLinked instructionsAfterFree instructionsBefore instructionsAfter |
	calledCompiledMethod := self createMethodOopFromHostMethod:
		                        self class >> #myYourself.

	selector := self newOldSpaceObjectWithSlots: 0.

	staticCallerCompiledMethod := methodBuilder newMethod
		                              literalAt: 0
		                              put: (memory integerObjectOf: 13);
		                              literalAt: 1
		                              put: calledCompiledMethod;
		                              literalAt: 2 put: selector;
		                              literalAt: 3 put: memory nilObject;
		                              bytecodes: #[ 32 246 1 92 ];
		                              buildMethod. "PushLiteral 1" "Static Send literal at 2" "Return top"

	cogit generateSendTrampolines.
	staticCallerCogMethod := cogit
		                         cog: staticCallerCompiledMethod
		                         selector: memory nilObject.
	staticCallTargetCogMethod := cogit
		                             cog: calledCompiledMethod
		                             selector: memory nilObject.
	
	

	builder := self machineCodeFrameBuilder.
	builder returnAddress: callerAddress.
	builder receiver: memory falseObject.
	builder method: staticCallerCogMethod.
	builder buildFrame.

	interpreter stackPointer:
		machineSimulator smalltalkStackPointerRegisterValue.
	interpreter framePointer: machineSimulator framePointerRegisterValue.

	"Push receiver, arg, then send"
	"interpreter push: (memory integerObjectOf: 13)."
	"	interpreter push: 16r320000460."

	"machineSimulator smalltalkStackPointerRegisterValue:
		interpreter stackPointer."


instructionsUnlinked := self
		                      getInstructionsStartingFrom:
		                      staticCallerCogMethod address
		                      + cogit noCheckEntryOffset
		                      to: staticCallTargetCogMethod address
			                      + staticCallTargetCogMethod stackCheckOffset.
	self
		runFrom: staticCallerCogMethod address + cogit noCheckEntryOffset
		until: staticCallTargetCogMethod address
			+ staticCallTargetCogMethod stackCheckOffset.

instructionsLinked := self
		                      getInstructionsStartingFrom:
		                      staticCallerCogMethod address
		                      + cogit noCheckEntryOffset
		                      to: staticCallTargetCogMethod address
			                      + staticCallTargetCogMethod stackCheckOffset.	
self assert: interpreter staticCallLinkCounter equals: 1.

	
	"Here we remove the method from compiled code space and see if the call site is linked back to its original state"

	self assert: (cogit coInterpreter methodHasCogMethod: staticCallTargetCogMethod  methodObject ).
	cogit freeMethod: staticCallTargetCogMethod.
	self deny: (cogit coInterpreter methodHasCogMethod: staticCallTargetCogMethod  methodObject ).
	instructionsAfterFree := self
		                     getInstructionsStartingFrom:
		                     staticCallerCogMethod address
		                     + cogit noCheckEntryOffset
		                     to: staticCallTargetCogMethod address
			                     + staticCallTargetCogMethod stackCheckOffset.
			1 halt.
self
		runFrom: staticCallerCogMethod address + cogit noCheckEntryOffset
		until: staticCallTargetCogMethod address
			+ staticCallTargetCogMethod stackCheckOffset. 

self
		runFrom: staticCallerCogMethod address + cogit noCheckEntryOffset
		until: staticCallTargetCogMethod address
			+ staticCallTargetCogMethod stackCheckOffset.
	"self openMachineDebuggerAt: staticCallerCogMethod address + cogit noCheckEntryOffset"

	self
		assert: machineSimulator instructionPointerRegisterValue
		equals: staticCallTargetCogMethod address
			+ staticCallTargetCogMethod stackCheckOffset.
	self assert: interpreter staticCallLinkCounter equals: 1.
	

	self
		runFrom: staticCallerCogMethod address + cogit noCheckEntryOffset
		until: staticCallTargetCogMethod address
			+ staticCallTargetCogMethod stackCheckOffset.

	

	self
		assert: (instructionsBefore collect: #asString)
		equals: (instructionsAfter collect: #asString).
]

{ #category : 'tests - sends static' }
VMStackToRegisterMappingStaticMessageSendTest >> testStaticSendOfCeStaticMethod [

	| selector calledCompiledMethod staticCallerCompiledMethod staticCallerCogMethod builder |

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

	builder := self machineCodeFrameBuilder.
	builder returnAddress: callerAddress.
	builder receiver: memory falseObject.
	builder method: staticCallerCogMethod.
	builder buildFrame.
	
	interpreter stackPointer: machineSimulator smalltalkStackPointerRegisterValue.
	interpreter framePointer: machineSimulator framePointerRegisterValue.
	
	"Push receiver, arg, then send"
	interpreter push: (memory integerObjectOf: 13).
	interpreter push: 16r320000460 .
	
	"Sending the static message will come back to the machine code, we need to stop it and see if we are in the correct place"
	[interpreter ceStaticSendInterpreted: calledCompiledMethod] 
		on: ReenterMachineCode 
		do: [] .

	self assert: interpreter stackTop equals: (memory integerObjectOf: 13).
	self assert: (interpreter stackValue: 1) equals: 16r320000460.
	self assert: machineSimulator pc equals: cogit getEnterCogCodePopReceiverReg 

]

{ #category : 'as yet unclassified' }
VMStackToRegisterMappingStaticMessageSendTest >> testStaticSendOfCeStaticMethodAmelioration [

	| selector calledCompiledMethod staticCallerCompiledMethod staticCallerCogMethod builder staticCallTargetCogMethod |
	calledCompiledMethod := self createMethodOopFromHostMethod:
		                        self class >> #myYourself.

	selector := self newOldSpaceObjectWithSlots: 0.

	staticCallerCompiledMethod := methodBuilder newMethod
		                              literalAt: 0
		                              put: (memory integerObjectOf: 13);
		                              literalAt: 1
		                              put: calledCompiledMethod;
		                              literalAt: 2 put: selector;
		                              literalAt: 3 put: memory nilObject;
		                              bytecodes: #[ 32 246 1 92 ];
		                              buildMethod. "PushLiteral 1" "Static Send literal at 2" "Return top"

	cogit generateSendTrampolines.
	staticCallerCogMethod := cogit
		                         cog: staticCallerCompiledMethod
		                         selector: memory nilObject.
	staticCallTargetCogMethod := cogit
		                             cog: calledCompiledMethod
		                             selector: memory nilObject.


	builder := self machineCodeFrameBuilder.
	builder returnAddress: callerAddress.
	builder receiver: memory falseObject.
	builder method: staticCallerCogMethod.
	builder buildFrame.

	interpreter stackPointer:
		machineSimulator smalltalkStackPointerRegisterValue.
	interpreter framePointer: machineSimulator framePointerRegisterValue.

	"Push receiver, arg, then send"
	"interpreter push: (memory integerObjectOf: 13)."
	"	interpreter push: 16r320000460."

	"machineSimulator smalltalkStackPointerRegisterValue:
		interpreter stackPointer."

	self
		runFrom: staticCallerCogMethod address + cogit noCheckEntryOffset
		until: staticCallTargetCogMethod address
			+ staticCallTargetCogMethod stackCheckOffset.

	self
		assert: machineSimulator instructionPointerRegisterValue
		equals: staticCallTargetCogMethod address
			+ staticCallTargetCogMethod stackCheckOffset.
	"We are at the beginning of the called method"

	"self
		assert: (interpreter stackValue: 3)
		equals: (memory integerObjectOf: 13).
	self assert: (interpreter stackValue: 1) equals: 16r320000460.
	self
		assert: machineSimulator pc
		equals: cogit getEnterCogCodePopReceiverReg"
]

{ #category : 'tests' }
VMStackToRegisterMappingStaticMessageSendTest >> testStaticSendOfCeStaticMethodIntialVersion [

	| selector calledCompiledMethod staticCallerCompiledMethod staticCallerCogMethod builder |

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

	builder := self machineCodeFrameBuilder.
	builder returnAddress: callerAddress.
	builder receiver: memory falseObject.
	builder method: staticCallerCogMethod.
	builder buildFrame.
	
	interpreter stackPointer: machineSimulator smalltalkStackPointerRegisterValue.
	interpreter framePointer: machineSimulator framePointerRegisterValue.
	
	"Push receiver, arg, then send"
	interpreter push: (memory integerObjectOf: 13).
	interpreter push: 16r320000460 .
	
	"Sending the static message will come back to the machine code, we need to stop it and see if we are in the correct place"
	[interpreter ceStaticSendInterpreted: calledCompiledMethod] 
		on: ReenterMachineCode 
		do: [] .

	self assert: interpreter stackTop equals: (memory integerObjectOf: 13).
	self assert: (interpreter stackValue: 1) equals: 16r320000460.
	self assert: machineSimulator pc equals: cogit getEnterCogCodePopReceiverReg 

]

{ #category : 'as yet unclassified' }
VMStackToRegisterMappingStaticMessageSendTest >> testStaticSendOfCoggedMethodCallMethodDirectly [

	| selector calledCompiledMethod calledCogMethod staticCallerCompiledMethod staticCallerCogMethod |

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

{ #category : 'as yet unclassified' }
VMStackToRegisterMappingStaticMessageSendTest >> testStaticSendOfNonCoggedMethodActivatesCorrectMethod [

	| selector calledCompiledMethod staticCallerCompiledMethod staticCallerCogMethod |

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
		
	self assert: machineSimulator receiverRegisterValue equals: (memory integerObjectOf: 13)
]

{ #category : 'as yet unclassified' }
VMStackToRegisterMappingStaticMessageSendTest >> testStaticSendOfNonCoggedMethodCallsTrampoline [

	| selector calledCompiledMethod staticCallerCompiledMethod staticCallerCogMethod |

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
		until: cogit staticSendTrampoline0. 
	self assert: machineSimulator pc equals: cogit staticSendTrampoline0.
	self assert: machineSimulator classRegisterValue equals: calledCompiledMethod 
]

{ #category : 'as yet unclassified' }
VMStackToRegisterMappingStaticMessageSendTest >> testStaticSendPatching [

	| selector calledCompiledMethod staticCallerCompiledMethod staticCallerCogMethod builder staticCallTargetCogMethod instructionsBefore instructionsAfter |
	calledCompiledMethod := self createMethodOopFromHostMethod:
		                        self class >> #myYourself.

	selector := self newOldSpaceObjectWithSlots: 0.

	staticCallerCompiledMethod := methodBuilder newMethod
		                              literalAt: 0
		                              put: (memory integerObjectOf: 13);
		                              literalAt: 1
		                              put: calledCompiledMethod;
		                              literalAt: 2 put: selector;
		                              literalAt: 3 put: memory nilObject;
		                              bytecodes: #[ 32 246 1 92 ];
		                              buildMethod. "PushLiteral 1" "Static Send literal at 2" "Return top"

	cogit generateSendTrampolines.
	staticCallerCogMethod := cogit
		                         cog: staticCallerCompiledMethod
		                         selector: memory nilObject.
	staticCallTargetCogMethod := cogit
		                             cog: calledCompiledMethod
		                             selector: memory nilObject.


	builder := self machineCodeFrameBuilder.
	builder returnAddress: callerAddress.
	builder receiver: memory falseObject.
	builder method: staticCallerCogMethod.
	builder buildFrame.

	interpreter stackPointer:
		machineSimulator smalltalkStackPointerRegisterValue.
	interpreter framePointer: machineSimulator framePointerRegisterValue.

	"Push receiver, arg, then send"
	"interpreter push: (memory integerObjectOf: 13)."
	"	interpreter push: 16r320000460."

	"machineSimulator smalltalkStackPointerRegisterValue:
		interpreter stackPointer."


	instructionsBefore := self
		                      getInstructionsStartingFrom:
		                      staticCallerCogMethod address
		                      + cogit noCheckEntryOffset
		                      to: staticCallTargetCogMethod address
			                      + staticCallTargetCogMethod stackCheckOffset.

	self
		runFrom: staticCallerCogMethod address + cogit noCheckEntryOffset
		until: staticCallTargetCogMethod address
			+ staticCallTargetCogMethod stackCheckOffset.

	instructionsAfter := self
		                     getInstructionsStartingFrom:
		                     staticCallerCogMethod address
		                     + cogit noCheckEntryOffset
		                     to: staticCallTargetCogMethod address
			                     + staticCallTargetCogMethod stackCheckOffset.

	{
		instructionsBefore.
		instructionsAfter }.
	self
		deny: (instructionsBefore collect: #asString)
		equals: (instructionsAfter collect: #asString).

	self assert:( (instructionsBefore collect: #asString) at: 32) equals: ((instructionsAfter collect: #asString) at: 32).
	self
		deny: ((instructionsBefore collect: #asString) at: 23)
		equals: ((instructionsAfter collect: #asString) at: 23). "
self openMachineDebuggerAt: staticCallerCogMethod address + cogit noCheckEntryOffset"
	self
		assert: machineSimulator instructionPointerRegisterValue
		equals: staticCallTargetCogMethod address
			+ staticCallTargetCogMethod stackCheckOffset
	"We are at the beginning of the called method"

	"self
		assert: (interpreter stackValue: 3)
		equals: (memory integerObjectOf: 13).
	self assert: (interpreter stackValue: 1) equals: 16r320000460.
	self
		assert: machineSimulator pc
		equals: cogit getEnterCogCodePopReceiverReg"
]

{ #category : 'beforeCall' }
VMStackToRegisterMappingStaticMessageSendTest >> testUnlinkingAffectsStaticSend [


	| selector calledCompiledMethod staticCallerCompiledMethod staticCallerCogMethod builder staticCallTargetCogMethod instructionsBefore instructionsAfter |
	
	selector := self newOldSpaceObjectWithSlots: 0.


	cogit ceSmallActiveContextInFullBlockTrampoline: (self compile: [
			 cogit.
			 cogit RetN: 0 ]).
	
	staticCallerCompiledMethod :=self createMethodOopFromHostMethod:
		                        self class >> #callMySelf.

calledCompiledMethod:=  memory fetchPointer: 1 ofObject: staticCallerCompiledMethod. 
self assert: (memory isCompiledMethod: calledCompiledMethod).
 
	cogit generateSendTrampolines.
	staticCallerCogMethod := cogit
		                         cog: staticCallerCompiledMethod
		                         selector: memory nilObject.
	staticCallTargetCogMethod := cogit
		                             cog: calledCompiledMethod
		                             selector: memory nilObject.


	builder := self machineCodeFrameBuilder.
	builder returnAddress: callerAddress.
	builder receiver: memory falseObject.
	builder method: staticCallerCogMethod.
	builder buildFrame.

	interpreter stackPointer:
		machineSimulator smalltalkStackPointerRegisterValue.
	interpreter framePointer: machineSimulator framePointerRegisterValue.

	self
		runFrom: staticCallerCogMethod address + cogit noCheckEntryOffset
		until: staticCallTargetCogMethod address
			+ staticCallTargetCogMethod stackCheckOffset.


	instructionsBefore := self
		                      getInstructionsStartingFrom:
		                      staticCallerCogMethod address
		                      + cogit noCheckEntryOffset
		                      to: staticCallTargetCogMethod address
			                      + staticCallTargetCogMethod stackCheckOffset.

	self
		assert: (instructionsBefore at: 22) assemblyCodeString
		equals: 'ldr	x1, #40'. " x1 here is the tempReg"
	self assert:
		(memory isOopCompiledMethod: (machineSimulator memory longAt:
				  (instructionsBefore at: 22) address + 40)).
	self
		assert: (machineSimulator memory longAt:
				 (instructionsBefore at: 22) address + 40)
		equals: calledCompiledMethod.
	self
		assert: machineSimulator instructionPointerRegisterValue
		equals: staticCallTargetCogMethod address
			+ staticCallTargetCogMethod stackCheckOffset.
	"---"
	instructionsAfter := self
		                      getInstructionsStartingFrom:
		                      staticCallerCogMethod address
		                      + cogit noCheckEntryOffset
		                      to: staticCallTargetCogMethod address
			                      + staticCallTargetCogMethod stackCheckOffset.

	self
		assert: (instructionsAfter at: 22) assemblyCodeString
		equals: 'ldr	x1, #40'. " x1 here is the tempReg"
	self assert:
		(memory isOopCompiledMethod: (machineSimulator memory longAt:
				  (instructionsAfter at: 22) address + 40)).
	self
		assert: (machineSimulator memory longAt:
				 (instructionsAfter at: 22) address + 40)
		equals: calledCompiledMethod.
	self
		assert: machineSimulator instructionPointerRegisterValue
		equals: staticCallTargetCogMethod address
			+ staticCallTargetCogMethod stackCheckOffset.
	"unlink ne fait cce qu'il faut"
1 halt.
	cogit printCogMethods
	cogit unlinkSendsTo: calledCompiledMethod  andFreeIf: true.
	
"	cogit freeMethod: staticCallTargetCogMethod."

	self
		deny: (instructionsBefore at: 23) assemblyCodeString
		equals: (instructionsAfter at: 23) assemblyCodeString.
	self
		assert: (instructionsAfter at: 22) assemblyCodeString
		equals: 'ldr	x1, #40'. " x1 here is the tempReg"
	self assert:
		(memory isOopCompiledMethod: (machineSimulator memory longAt:
				  (instructionsAfter at: 22) address + 40)).
	self
		assert: (machineSimulator memory longAt:
				 (instructionsAfter at: 22) address + 40)
		equals: calledCompiledMethod.
]

{ #category : 'beforeCall' }
VMStackToRegisterMappingStaticMessageSendTest >> testUnlinkingHasNoEffectOnNormalSend [

	| selector calledCompiledMethod staticCallerCompiledMethod staticCallerCogMethod builder staticCallTargetCogMethod instructionsBefore instructionsAfter |
	calledCompiledMethod := self createMethodOopFromHostMethod:
		                        self class >> #myYourself.

	selector := self newOldSpaceObjectWithSlots: 0.


	cogit ceSmallActiveContextInFullBlockTrampoline: (self compile: [
			 cogit.
			 cogit RetN: 0 ]).

	staticCallerCompiledMethod := methodBuilder newMethod
		                              literalAt: 0
		                              put: (memory integerObjectOf: 13);
		                              literalAt: 1
		                              put: calledCompiledMethod;
		                              literalAt: 2 put: selector;
		                              literalAt: 3 put: memory nilObject;
		                              bytecodes: #[ 32 246 1 92 ];
		                              buildMethod. "PushLiteral 1" "Static Send literal at 2" "Return top"

	cogit generateSendTrampolines.
	staticCallerCogMethod := cogit
		                         cog: staticCallerCompiledMethod
		                         selector: memory nilObject.
	staticCallTargetCogMethod := cogit
		                             cog: calledCompiledMethod
		                             selector: memory nilObject.

	builder := self machineCodeFrameBuilder.
	builder returnAddress: callerAddress.
	builder receiver: memory falseObject.
	builder method: staticCallerCogMethod.
	builder buildFrame.

	interpreter stackPointer:
		machineSimulator smalltalkStackPointerRegisterValue.
	interpreter framePointer: machineSimulator framePointerRegisterValue.

	instructionsBefore := self
		                      getInstructionsStartingFrom:
		                      staticCallerCogMethod address
		                      + cogit noCheckEntryOffset
		                      to: staticCallTargetCogMethod address
			                      + staticCallTargetCogMethod stackCheckOffset.
	self
		runFrom: staticCallerCogMethod address + cogit noCheckEntryOffset
		until: staticCallTargetCogMethod address
			+ staticCallTargetCogMethod stackCheckOffset.


	instructionsAfter := self
		                      getInstructionsStartingFrom:
		                      staticCallerCogMethod address
		                      + cogit noCheckEntryOffset
		                      to: staticCallTargetCogMethod address
			                      + staticCallTargetCogMethod stackCheckOffset.

	self
		assert: (instructionsAfter at: 22) assemblyCodeString
		equals: 'ldr	x1, #40'. " x1 here is the tempReg"
	self assert:
		(memory isOopCompiledMethod: (machineSimulator memory longAt:
				  (instructionsAfter at: 22) address + 40)).
	self
		assert: (machineSimulator memory longAt:
				 (instructionsAfter at: 22) address + 40)
		equals: calledCompiledMethod.
	self
		assert: machineSimulator instructionPointerRegisterValue
		equals: staticCallTargetCogMethod address
			+ staticCallTargetCogMethod stackCheckOffset.
	
	cogit unlinkSendsTo: staticCallTargetCogMethod address  andFreeIf: true.
	cogit freeUnmarkedMachineCode.
	cogit freeMethod: staticCallTargetCogMethod.
	self
		assert: (instructionsAfter at: 22) assemblyCodeString
		equals: 'ldr	x1, #40'. " x1 here is the tempReg"
	self assert:
		(memory isOopCompiledMethod: (machineSimulator memory longAt:
				  (instructionsAfter at: 22) address + 40)).
	self
		assert: (machineSimulator memory longAt:
				 (instructionsAfter at: 22) address + 40)
		equals: calledCompiledMethod.
]
