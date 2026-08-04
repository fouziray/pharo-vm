Class {
	#name : 'VMJITVMPrimitiveTest',
	#superclass : 'VMPrimitiveCallAbstractTest',
	#category : 'VMMakerTests-JitTests',
	#package : 'VMMakerTests',
	#tag : 'JitTests'
}

{ #category : 'special selectors' }
VMJITVMPrimitiveTest >> associateSpecialSelectorArrayTotTest [
| splObjectArrayFromImage |
splObjectArrayFromImage := PointerUtils oopForObject:  (Smalltalk specialSelectors) pin.
	memory specialObjectsOop:splObjectArrayFromImage .    
]

{ #category : 'tests' }
VMJITVMPrimitiveTest >> installSelector: aSelectorOop method: aMethodOop inMethodDictionary: aMethodDictionary [
	
	| anArrayOfMethods |
	anArrayOfMethods := memory
		                    fetchPointer: MethodArrayIndex
		                    ofObject: aMethodDictionary.
	memory
		storePointer:
		(memory methodDictionaryHash: aSelectorOop mask: 11) + 2
		ofObject: aMethodDictionary
		withValue: aSelectorOop.
	memory
		storePointer: (memory methodDictionaryHash: aSelectorOop mask: 11)
		ofObject: anArrayOfMethods
		withValue: aMethodOop
]

{ #category : 'primitive cache setting' }
VMJITVMPrimitiveTest >> linkPicWithCases: sizeOfPic withIntegerAtPosition: aPosition [

	"We create two target type and methods arrays, with sizes > to the size of pic limit (6).
	
	We fill it with types and fresh methods, making sure that the nth position has the integer type, which we will look for matching"
	| targetTypes targetMethods |
	targetTypes := self newArrayWithSlots: sizeOfPic.
	targetMethods := self newArrayWithSlots: sizeOfPic.

	1 to: sizeOfPic do: [:i|
		| targetType targetMethod |
		
		targetType := i == aPosition ifTrue: [
			self setSmallIntegerClassIntoClassTable.
		] ifFalse: [
			self setSmallFloatClassIntoClassTable.
		].
		memory
			storePointer: i - 1
			ofObject: targetTypes
			withValue: targetType.
		
		targetMethod := methodBuilder 
			bytecodes: #[
				16r4C "push self"
				16r5C "ret top"
			];
			buildMethod.
		memory
			storePointer: i - 1
			ofObject: targetMethods
			withValue: targetMethod.
	].
	^ { targetTypes . targetMethods }
]

{ #category : 'accessing' }
VMJITVMPrimitiveTest >> sendSiteToSet [

	obj1  yourself.
	^ 12 
]

{ #category : 'tests - primitiveMethodXray' }
VMJITVMPrimitiveTest >> setUp [

	super setUp.

	interpreter messageSelector: memory nilObject.

	self setUpTrampolines.
	self setUpCogMethodEntry.
	self createBaseFrame
]

{ #category : 'primitive cache setting' }
VMJITVMPrimitiveTest >> testPrimitiveMethodCacheReSettingPolymorphic [
	| targetTypes targetMethods sourceMethod bcpc positionToMatch targetArrays |

	positionToMatch := 3.
	
	sourceMethod := methodBuilder
		bytecodes: #[ 
			16r4C "push self"
			16r80 "send 0 arg"
			16r5C "ret top"
		];
		buildMethod.
			
	"Go 2 bytes after the beginning of the method.
	This is the byte following the send!"
	bcpc := (interpreter startPCOfMethod: sourceMethod) + 2. 
	
	targetArrays := self linkPicWithCases: 3 withIntegerAtPosition: positionToMatch.
	targetTypes := targetArrays first.
	targetMethods := targetArrays second.
	

	"sourceMethod"
	interpreter push: sourceMethod.
	"bcpc"
	interpreter push: (memory integerObjectOf: bcpc).
	"target types"
	interpreter push: targetTypes.
	"target methods"
	interpreter push: targetMethods.

	interpreter argumentCount: 4.
	interpreter primitiveMethodCacheSetting.

	self
		prepareStackForSendReceiver: (memory integerObjectOf: 3) 
		arguments: { }.

	self
		runFrom: (interpreter cogMethodOf: sourceMethod ) address + cogit noCheckEntryOffset
		until: (interpreter cogMethodOf: (memory fetchPointer: positionToMatch - 1 ofObject: targetMethods)) address + cogit noCheckEntryOffset.
		
"We reset the source method to contain a newer pic.
We create a new pic, the target methods have new oop.
Then check if the rewriting on a previously set site works"
targetArrays := self linkPicWithCases: 3 withIntegerAtPosition: positionToMatch.
	targetTypes := targetArrays first.
	targetMethods := targetArrays second.
	
	"sourceMethod"
	interpreter push: sourceMethod.
	"bcpc"
	interpreter push: (memory integerObjectOf: bcpc).
	"target types"
	interpreter push: targetTypes.
	"target methods"
	interpreter push: targetMethods.

	interpreter argumentCount: 4.
	interpreter primitiveMethodCacheSetting.
	
	self
		prepareStackForSendReceiver: (memory integerObjectOf: 3) 
		arguments: { }.

	self
		runFrom: (interpreter cogMethodOf: sourceMethod ) address + cogit noCheckEntryOffset
		until: (interpreter cogMethodOf: (memory fetchPointer: positionToMatch - 1 ofObject: targetMethods)) address + cogit noCheckEntryOffset.
		

]

{ #category : 'primitive cache setting' }
VMJITVMPrimitiveTest >> testPrimitiveMethodCacheSettingMonomorphic [

	| targetTypes targetMethods sourceMethod arrayClass bcpc targetMethod |
	sourceMethod := methodBuilder
		bytecodes: #[ 
			16r4C "push self"
			16r80 "send 0 arg"
			16r5C "ret top"
		];
		buildMethod.
	targetMethod := methodBuilder 
		bytecodes: #[ 
			16r4C "push self"
			16r5C "ret top"
		];
		buildMethod.

	"Go 2 bytes after the beginning of the method.
	This is the byte following the send!"
	bcpc := (interpreter startPCOfMethod: sourceMethod) + 2. 
	arrayClass := self createArrayClass.

	"We create two target type and methods arrays, with sizes > to the size of pic limit (6)"
	targetTypes := self newArrayWithSlots: 1.
	targetMethods := self newArrayWithSlots: 1.

	memory
		storePointer: 0
		ofObject: targetMethods
		withValue: targetMethod.
	memory
		storePointer: 0
		ofObject: targetTypes
		withValue: arrayClass.


	"sourceMethod"
	interpreter push: sourceMethod.
	"bcpc"
	interpreter push: (memory integerObjectOf: bcpc).
	"target types"
	interpreter push: targetTypes.
	"target methods"
	interpreter push: targetMethods.

	interpreter argumentCount: 4.
	interpreter primitiveMethodCacheSetting.

	self
		prepareStackForSendReceiver: memory nilObject
		arguments: { }.

	self
		runFrom: (interpreter cogMethodOf: sourceMethod) address + cogit noCheckEntryOffset
		until: (interpreter cogMethodOf: targetMethod) address + cogit entryOffset
]

{ #category : 'primitive cache setting' }
VMJITVMPrimitiveTest >> testPrimitiveMethodCacheSettingMonomorphicCompilesSourceMethod [

	| targetTypes targetMethods sourceMethod arrayClass bcpc targetMethod |
	sourceMethod := methodBuilder
		bytecodes: #[ 
			16r4C "push self"
			16r80 "send 0 arg"
			16r5C "ret top"
		];
		buildMethod.
	targetMethod := methodBuilder 
		bytecodes: #[ 
			16r4C "push self"
			16r5C "ret top"
		];
		buildMethod.
	bcpc := (interpreter startPCOfMethod: sourceMethod) + 1. 
	arrayClass := self createArrayClass.

	"We create two target type and methods arrays, with sizes > to the size of pic limit (6)"
	targetTypes := self newArrayWithSlots: 1.
	targetMethods := self newArrayWithSlots: 1.

	memory
		storePointer: 0
		ofObject: targetMethods
		withValue: targetMethod .
	memory
		storePointer: 0
		ofObject: targetTypes
		withValue: arrayClass.


	"sourceMethod"
	interpreter push: sourceMethod.
	"bcpc"
	interpreter push: bcpc.
	"target types"
	interpreter push: targetTypes.
	"target methods"
	interpreter push: targetMethods.

	interpreter argumentCount: 4.
	interpreter primitiveMethodCacheSetting.

	self assert: (interpreter methodHasCogMethod: sourceMethod)
]

{ #category : 'primitive cache setting' }
VMJITVMPrimitiveTest >> testPrimitiveMethodCacheSettingMonomorphicCompilesTargetMethod [

	| targetTypes targetMethods sourceMethod arrayClass bcpc targetMethod |
	
	interpreter messageSelector: (memory pinObject: (memory stringForCString: #yourself)).
	
	sourceMethod := methodBuilder
		bytecodes: #[ 
			16r4C "push self"
			16r80 "send 0 arg"
			16r5C "ret top"
		];
		buildMethod.
	
	targetMethod := methodBuilder 
		bytecodes: #[ 
			16r4C "push self"
			16r5C "ret top"
		];
		buildMethod.
		
	"Go 2 bytes after the beginning of the method.
	This is the byte following the send!"
	
	bcpc := (interpreter startPCOfMethod: sourceMethod) + 2. 
	
	arrayClass := self createArrayClass.

	"We create two target type and methods arrays, with sizes > to the size of pic limit (6)"
	targetTypes := self newArrayWithSlots: 1.
	targetMethods := self newArrayWithSlots: 1.

	memory
		storePointer: 0
		ofObject: targetMethods
		withValue: targetMethod.
	memory
		storePointer: 0
		ofObject: targetTypes
		withValue: arrayClass.


	"sourceMethod"
	interpreter push: sourceMethod.
	"bcpc"
	interpreter push: (memory integerObjectOf: bcpc).
	"target types"
	interpreter push: targetTypes.
	"target methods"
	interpreter push: targetMethods.

	interpreter argumentCount: 4.
	interpreter primitiveMethodCacheSetting.

	self assert: (interpreter methodHasCogMethod: targetMethod)
]

{ #category : 'primitive cache setting' }
VMJITVMPrimitiveTest >> testPrimitiveMethodCacheSettingMonomorphicWithWrongBytecodePCFails [

	| targetTypes targetMethods sourceMethod arrayClass bcpc targetMethod |
	sourceMethod := methodBuilder
		bytecodes: #[ 
			16r4C "push self"
			16r80 "send 0 arg"
			16r5C "ret top"
		];
		buildMethod.
	targetMethod := methodBuilder 
		bytecodes: #[ 
			16r4C "push self"
			16r5C "ret top"
		];
		buildMethod.
	
	"This is the send BCPC, which is wrong.
	We should provide the following PC, the send return PC"
	bcpc := (interpreter startPCOfMethod: sourceMethod) + 1. 
	arrayClass := self createArrayClass.

	"We create two target type and methods arrays, with sizes > to the size of pic limit (6)"
	targetTypes := self newArrayWithSlots: 1.
	targetMethods := self newArrayWithSlots: 1.

	memory
		storePointer: 0
		ofObject: targetMethods
		withValue: targetMethod .
	memory
		storePointer: 0
		ofObject: targetTypes
		withValue: arrayClass.


	"sourceMethod"
	interpreter push: sourceMethod.
	"bcpc"
	interpreter push: bcpc.
	"target types"
	interpreter push: targetTypes.
	"target methods"
	interpreter push: targetMethods.

	interpreter argumentCount: 4.
	interpreter primitiveMethodCacheSetting.

	self assert: interpreter failed
]

{ #category : 'primitive cache setting' }
VMJITVMPrimitiveTest >> testPrimitiveMethodCacheSettingPolymorphic2CasesMatchFirstType [

	| targetTypes targetMethods sourceMethod bcpc positionToMatch targetArrays |

	positionToMatch := 1.
	
	sourceMethod := methodBuilder
		bytecodes: #[ 
			16r4C "push self"
			16r80 "send 0 arg"
			16r5C "ret top"
		];
		buildMethod.
			
	"Go 2 bytes after the beginning of the method.
	This is the byte following the send!"
	bcpc := (interpreter startPCOfMethod: sourceMethod) + 2. 
	
	targetArrays := self linkPicWithCases: 2 withIntegerAtPosition: positionToMatch.
	targetTypes := targetArrays first.
	targetMethods := targetArrays second.
	

	"sourceMethod"
	interpreter push: sourceMethod.
	"bcpc"
	interpreter push: (memory integerObjectOf: bcpc).
	"target types"
	interpreter push: targetTypes.
	"target methods"
	interpreter push: targetMethods.

	interpreter argumentCount: 4.
	interpreter primitiveMethodCacheSetting.

	self
		prepareStackForSendReceiver: (memory integerObjectOf: 3) 
		arguments: { }.

	self
		runFrom: (interpreter cogMethodOf: sourceMethod ) address + cogit noCheckEntryOffset
		until: (interpreter cogMethodOf: (memory fetchPointer: positionToMatch - 1 ofObject: targetMethods)) address + cogit noCheckEntryOffset 
]

{ #category : 'primitive cache setting' }
VMJITVMPrimitiveTest >> testPrimitiveMethodCacheSettingPolymorphic2CasesMatchSecondType [

	| targetTypes targetMethods sourceMethod bcpc positionToMatch targetArrays |

	positionToMatch := 2.
	
	sourceMethod := methodBuilder
		bytecodes: #[ 
			16r4C "push self"
			16r80 "send 0 arg"
			16r5C "ret top"
		];
		buildMethod.
			
	"Go 2 bytes after the beginning of the method.
	This is the byte following the send!"
	bcpc := (interpreter startPCOfMethod: sourceMethod) + 2. 
	
	targetArrays := self linkPicWithCases: 2 withIntegerAtPosition: positionToMatch.
	targetTypes := targetArrays first.
	targetMethods := targetArrays second.
	

	"sourceMethod"
	interpreter push: sourceMethod.
	"bcpc"
	interpreter push: (memory integerObjectOf: bcpc).
	"target types"
	interpreter push: targetTypes.
	"target methods"
	interpreter push: targetMethods.

	interpreter argumentCount: 4.
	interpreter primitiveMethodCacheSetting.

	self
		prepareStackForSendReceiver: (memory integerObjectOf: 3) 
		arguments: { }.

	self
		runFrom: (interpreter cogMethodOf: sourceMethod ) address + cogit noCheckEntryOffset
		until: (interpreter cogMethodOf: (memory fetchPointer: positionToMatch - 1 ofObject: targetMethods)) address + cogit noCheckEntryOffset 
]

{ #category : 'primitive cache setting' }
VMJITVMPrimitiveTest >> testPrimitiveMethodCacheSettingPolymorphic3CasesMatchFirstType [

	| targetTypes targetMethods sourceMethod bcpc positionToMatch targetArrays |

	positionToMatch := 1.
	
	sourceMethod := methodBuilder
		bytecodes: #[ 
			16r4C "push self"
			16r80 "send 0 arg"
			16r5C "ret top"
		];
		buildMethod.
			
	"Go 2 bytes after the beginning of the method.
	This is the byte following the send!"
	bcpc := (interpreter startPCOfMethod: sourceMethod) + 2. 
	
	targetArrays := self linkPicWithCases: 3 withIntegerAtPosition: positionToMatch.
	targetTypes := targetArrays first.
	targetMethods := targetArrays second.
	

	"sourceMethod"
	interpreter push: sourceMethod.
	"bcpc"
	interpreter push: (memory integerObjectOf: bcpc).
	"target types"
	interpreter push: targetTypes.
	"target methods"
	interpreter push: targetMethods.

	interpreter argumentCount: 4.
	interpreter primitiveMethodCacheSetting.

	self
		prepareStackForSendReceiver: (memory integerObjectOf: 3) 
		arguments: { }.

	self
		runFrom: (interpreter cogMethodOf: sourceMethod ) address + cogit noCheckEntryOffset
		until: (interpreter cogMethodOf: (memory fetchPointer: positionToMatch - 1 ofObject: targetMethods)) address + cogit noCheckEntryOffset 
]

{ #category : 'primitive cache setting' }
VMJITVMPrimitiveTest >> testPrimitiveMethodCacheSettingPolymorphic3CasesMatchSecondType [

	| targetTypes targetMethods sourceMethod bcpc positionToMatch targetArrays |

	positionToMatch := 2.
	
	sourceMethod := methodBuilder
		bytecodes: #[ 
			16r4C "push self"
			16r80 "send 0 arg"
			16r5C "ret top"
		];
		buildMethod.
			
	"Go 2 bytes after the beginning of the method.
	This is the byte following the send!"
	bcpc := (interpreter startPCOfMethod: sourceMethod) + 2. 
	
	targetArrays := self linkPicWithCases: 3 withIntegerAtPosition: positionToMatch.
	targetTypes := targetArrays first.
	targetMethods := targetArrays second.
	

	"sourceMethod"
	interpreter push: sourceMethod.
	"bcpc"
	interpreter push: (memory integerObjectOf: bcpc).
	"target types"
	interpreter push: targetTypes.
	"target methods"
	interpreter push: targetMethods.

	interpreter argumentCount: 4.
	interpreter primitiveMethodCacheSetting.

	self
		prepareStackForSendReceiver: (memory integerObjectOf: 3) 
		arguments: { }.

	self
		runFrom: (interpreter cogMethodOf: sourceMethod ) address + cogit noCheckEntryOffset
		until: (interpreter cogMethodOf: (memory fetchPointer: positionToMatch - 1 ofObject: targetMethods)) address + cogit noCheckEntryOffset 
]

{ #category : 'primitive cache setting' }
VMJITVMPrimitiveTest >> testPrimitiveMethodCacheSettingPolymorphic3CasesMatchThirdType [

	| targetTypes targetMethods sourceMethod bcpc positionToMatch targetArrays |

	positionToMatch := 3.
	
	sourceMethod := methodBuilder
		bytecodes: #[ 
			16r4C "push self"
			16r80 "send 0 arg"
			16r5C "ret top"
		];
		buildMethod.
			
	"Go 2 bytes after the beginning of the method.
	This is the byte following the send!"
	bcpc := (interpreter startPCOfMethod: sourceMethod) + 2. 
	
	targetArrays := self linkPicWithCases: 3 withIntegerAtPosition: positionToMatch.
	targetTypes := targetArrays first.
	targetMethods := targetArrays second.
	

	"sourceMethod"
	interpreter push: sourceMethod.
	"bcpc"
	interpreter push: (memory integerObjectOf: bcpc).
	"target types"
	interpreter push: targetTypes.
	"target methods"
	interpreter push: targetMethods.

	interpreter argumentCount: 4.
	interpreter primitiveMethodCacheSetting.

	self
		prepareStackForSendReceiver: (memory integerObjectOf: 3) 
		arguments: { }.

	self
		runFrom: (interpreter cogMethodOf: sourceMethod ) address + cogit noCheckEntryOffset
		until: (interpreter cogMethodOf: (memory fetchPointer: positionToMatch - 1 ofObject: targetMethods)) address + cogit noCheckEntryOffset 
]

{ #category : 'primitive cache setting' }
VMJITVMPrimitiveTest >> testPrimitiveMethodCacheSettingWithBCPCNotAnInteger [

	| emptyArray sourceMethod |
	emptyArray := self newArrayWithSlots: 0.
	sourceMethod := methodBuilder buildMethod.

	"sourceMethod"
	interpreter push: sourceMethod.
	"bcpc"
	interpreter push: memory nilObject.
	"target types"
	interpreter push: emptyArray.
	"target methods"
	interpreter push: emptyArray.
	
	interpreter argumentCount: 4.
	interpreter primitiveMethodCacheSetting.

	self assert: interpreter failed.
	self assert: interpreter primFailCode equals: PrimErrBadArgument
]

{ #category : 'primitive cache setting' }
VMJITVMPrimitiveTest >> testPrimitiveMethodCacheSettingWithLessArguments [


	"We simulate calling the primitive from a method with one argument less.
	4 is expected, 3 is not enough.
	This should fail the primitive"
	interpreter argumentCount: 3.
	interpreter primitiveMethodCacheSetting.

	self assert: interpreter failed.
	self assert: interpreter primFailCode equals: PrimErrBadNumArgs.
]

{ #category : 'primitive cache setting' }
VMJITVMPrimitiveTest >> testPrimitiveMethodCacheSettingWithSourceMethodAnImmediate [

	| emptyArray |
	emptyArray := self newArrayWithSlots: 0.

	"sourceMethod"
	interpreter push: (memory integerObjectOf: 42).
	"bcpc"
	interpreter push: (memory integerObjectOf: 17).
	"target types"
	interpreter push: emptyArray.
	"target methods"
	interpreter push: emptyArray.
	
	interpreter argumentCount: 4.
	interpreter primitiveMethodCacheSetting.

	self assert: interpreter failed.
	self assert: interpreter primFailCode equals: PrimErrBadMethod
]

{ #category : 'primitive cache setting' }
VMJITVMPrimitiveTest >> testPrimitiveMethodCacheSettingWithSourceMethodNotAMethod [

	| emptyArray |
	emptyArray := self newArrayWithSlots: 0.

	"sourceMethod"
	interpreter push: memory nilObject.
	"bcpc"
	interpreter push: (memory integerObjectOf: 17).
	"target types"
	interpreter push: emptyArray.
	"target methods"
	interpreter push: emptyArray.
	
	interpreter argumentCount: 4.
	interpreter primitiveMethodCacheSetting.

	self assert: interpreter failed.
	self assert: interpreter primFailCode equals: PrimErrBadMethod
]

{ #category : 'primitive cache setting' }
VMJITVMPrimitiveTest >> testPrimitiveMethodCacheSettingWithTargetMethodsAndTargetTypesSizesDoNotMatch [

	| targetTypes targetMethods sourceMethod |
	sourceMethod := methodBuilder buildMethod.

	"We create two target type and methods arrays, with different sizes"
	targetTypes := self newArrayWithSlots: 0.
	targetMethods := self newArrayWithSlots: 1.
	memory
		storePointer: 0
		ofObject: targetMethods
		withValue: sourceMethod.


	"sourceMethod"
	interpreter push: sourceMethod.
	"bcpc"
	interpreter push: (memory integerObjectOf: 17).
	"target types"
	interpreter push: targetTypes.
	"target methods"
	interpreter push: targetMethods.

	interpreter argumentCount: 4.
	interpreter primitiveMethodCacheSetting.

	self assert: interpreter failed.
	self assert: interpreter primFailCode equals: PrimErrBadArgument
]

{ #category : 'primitive cache setting' }
VMJITVMPrimitiveTest >> testPrimitiveMethodCacheSettingWithTargetMethodsAndTargetTypesSizesExceedPICLimit [

	| targetTypes targetMethods sourceMethod arrayClass |
	sourceMethod := methodBuilder buildMethod.
	arrayClass := self createArrayClass.

	"We create two target type and methods arrays, with sizes > to the size of pic limit (6)"
	targetTypes := self newArrayWithSlots: 7.
	targetMethods := self newArrayWithSlots: 7.
	0 to: 6 do: [ :i |
		memory
			storePointer: i
			ofObject: targetMethods
			withValue: sourceMethod.
		memory
			storePointer: i
			ofObject: targetTypes
			withValue: arrayClass ].


	"sourceMethod"
	interpreter push: sourceMethod.
	"bcpc"
	interpreter push: (memory integerObjectOf: 17).
	"target types"
	interpreter push: targetTypes.
	"target methods"
	interpreter push: targetMethods.

	interpreter argumentCount: 4.
	interpreter primitiveMethodCacheSetting.

	self assert: interpreter failed.
	self assert: interpreter primFailCode equals: PrimErrBadArgument
]

{ #category : 'primitive cache setting' }
VMJITVMPrimitiveTest >> testPrimitiveMethodCacheSettingWithTargetMethodsIsArrayWithIntegers [

	| emptyArray targetMethods sourceMethod |
	emptyArray := self newArrayWithSlots: 0.

	"we create an array with a an integer instead of a type"
	targetMethods := self newArrayWithSlots: 1.
	memory
		storePointer: 0
		ofObject: targetMethods
		withValue: (memory integerObjectOf: 42).
	sourceMethod := methodBuilder buildMethod.

	"sourceMethod"
	interpreter push: sourceMethod.
	"bcpc"
	interpreter push: (memory integerObjectOf: 17).
	"target types"
	interpreter push: emptyArray.
	"target methods"
	interpreter push: targetMethods.

	interpreter argumentCount: 4.
	interpreter primitiveMethodCacheSetting.

	self assert: interpreter failed.
	self assert: interpreter primFailCode equals: PrimErrBadArgument
]

{ #category : 'primitive cache setting' }
VMJITVMPrimitiveTest >> testPrimitiveMethodCacheSettingWithTargetMethodsIsArrayWithNonMethods [

	| emptyArray targetMethods sourceMethod |
	emptyArray := self newArrayWithSlots: 0.

	"we create an array with a nil instead of a type"
	targetMethods := self newArrayWithSlots: 1.
	memory
		storePointer: 0
		ofObject: targetMethods
		withValue: memory nilObject.
	sourceMethod := methodBuilder buildMethod.

	"sourceMethod"
	interpreter push: sourceMethod.
	"bcpc"
	interpreter push: (memory integerObjectOf: 17).
	"target types"
	interpreter push: emptyArray.
	"target methods"
	interpreter push: targetMethods.

	interpreter argumentCount: 4.
	interpreter primitiveMethodCacheSetting.

	self assert: interpreter failed.
	self assert: interpreter primFailCode equals: PrimErrBadArgument
]

{ #category : 'primitive cache setting' }
VMJITVMPrimitiveTest >> testPrimitiveMethodCacheSettingWithTargetMethodsNotAnArray [

	| emptyArray sourceMethod |
	emptyArray := self newArrayWithSlots: 0.
	sourceMethod := methodBuilder buildMethod.

	"sourceMethod"
	interpreter push: sourceMethod.
	"bcpc"
	interpreter push: (memory integerObjectOf: 17).
	"target types"
	interpreter push: emptyArray.
	"target methods"
	interpreter push: memory nilObject.

	interpreter argumentCount: 4.
	interpreter primitiveMethodCacheSetting.

	self assert: interpreter failed.
	self assert: interpreter primFailCode equals: PrimErrBadArgument
]

{ #category : 'primitive cache setting' }
VMJITVMPrimitiveTest >> testPrimitiveMethodCacheSettingWithTargetTypesIsArrayWithImmediateNonTypes [

	| emptyArray targetTypes sourceMethod |
	emptyArray := self newArrayWithSlots: 0.
	
	"we create an array with a an integer instead of a type"
	targetTypes := self newArrayWithSlots: 1.
	memory
		storePointer: 0
		ofObject: targetTypes
		withValue: (memory integerObjectOf: 42).
	sourceMethod := methodBuilder buildMethod.

	"sourceMethod"
	interpreter push: sourceMethod.
	"bcpc"
	interpreter push: (memory integerObjectOf: 17).
	"target types"
	interpreter push: targetTypes.
	"target methods"
	interpreter push: emptyArray.

	interpreter argumentCount: 4.
	interpreter primitiveMethodCacheSetting.

	self assert: interpreter failed.
	self assert: interpreter primFailCode equals: PrimErrBadArgument
]

{ #category : 'primitive cache setting' }
VMJITVMPrimitiveTest >> testPrimitiveMethodCacheSettingWithTargetTypesIsArrayWithNonTypes [

	| emptyArray targetTypes sourceMethod |
	emptyArray := self newArrayWithSlots: 0.
	
	"we create an array with a nil instead of a type"
	targetTypes := self newArrayWithSlots: 1.
	memory
		storePointer: 0
		ofObject: targetTypes
		withValue: memory nilObject.
	sourceMethod := methodBuilder buildMethod.

	"sourceMethod"
	interpreter push: sourceMethod.
	"bcpc"
	interpreter push: (memory integerObjectOf: 17).
	"target types"
	interpreter push: targetTypes.
	"target methods"
	interpreter push: emptyArray.

	interpreter argumentCount: 4.
	interpreter primitiveMethodCacheSetting.

	self assert: interpreter failed.
	self assert: interpreter primFailCode equals: PrimErrBadArgument
]

{ #category : 'primitive cache setting' }
VMJITVMPrimitiveTest >> testPrimitiveMethodCacheSettingWithTargetTypesNotAnArray [

	| emptyArray sourceMethod |
	emptyArray := self newArrayWithSlots: 0.
	sourceMethod := methodBuilder buildMethod.

	"sourceMethod"
	interpreter push: sourceMethod.
	"bcpc"
	interpreter push: (memory integerObjectOf: 17).
	"target types"
	interpreter push: memory nilObject.
	"target methods"
	interpreter push: emptyArray.
	
	interpreter argumentCount: 4.
	interpreter primitiveMethodCacheSetting.

	self assert: interpreter failed.
	self assert: interpreter primFailCode equals: PrimErrBadArgument
]

{ #category : 'tests - primitiveMethodXray' }
VMJITVMPrimitiveTest >> testPrimitiveMethodXRayPreviouslyCompiledFramelessMethod [

	| methodToXray target |
	
	"This test is only valid as far as the method is the same.
	It should be a method with so many literals that the compiler does not even try to compile it."
	target := (SlangBasicTranslationTestClass>>#first:second:).
	self assert: target bytecodes hash equals: 245997176.
	
	methodToXray := self jitMethod: target.
	interpreter push: methodToXray methodObject.

	interpreter primitiveMethodXray.

	"Are the third lowest bits turned on?"
	self assert: ((memory integerValueOf: interpreter stackTop) anyMask: 2r0111)
]

{ #category : 'tests - primitiveMethodXray' }
VMJITVMPrimitiveTest >> testPrimitiveMethodXRayShouldCompile [

	| methodToXray target |
	
	"This test is only valid as far as the method is the same.
	It should be a method with so many literals that the compiler does not even try to compile it."
	target := (SlangBasicTranslationTestClass>>#methodDefiningSingleExternVariable).
	self assert: target bytecodes hash equals: 222697369.
	
	methodToXray := self createMethodOopFromHostMethod: target.
	interpreter push: methodToXray.
	
	interpreter primitiveMethodXray.

	"Is the lowest bit turned on?"
	self assert: ((memory integerValueOf: interpreter stackTop) anyMask: 2r0001)
]

{ #category : 'tests - primitiveMethodXray' }
VMJITVMPrimitiveTest >> testPrimitiveMethodXRayShouldNotCompile [

	| methodToXray target |
	
	"This test is only valid as far as the method is the same.
	It should be a method with so many literals that the compiler does not even try to compile it."
	target := (CogARMv8Compiler class>>#initialize).
	self assert: target bytecodes hash equals: 46085044.
	
	methodToXray := self createMethodOopFromHostMethod: target.
	interpreter push: methodToXray.
	
	interpreter primitiveMethodXray.

	self assert: interpreter stackTop equals: (memory integerObjectOf: 0)
]

{ #category : 'tests - primitiveMethodXray' }
VMJITVMPrimitiveTest >> testPrimitiveMethodXRayWasCompiled [

	| methodToXray target |
	
	"This test is only valid as far as the method is the same.
	It should be a method with so many literals that the compiler does not even try to compile it."
	target := (SlangBasicTranslationTestClass>>#methodDefiningSingleExternVariable).
	self assert: target bytecodes hash equals: 222697369.
	
	methodToXray := self jitMethod: target.
	interpreter push: methodToXray methodObject.
	
	interpreter primitiveMethodXray.

	"Is the second lowest bit turned off"
	self assert: ((memory integerValueOf: interpreter stackTop) anyMask: 2r0010)
]

{ #category : 'tests - primitiveMethodXray' }
VMJITVMPrimitiveTest >> testPrimitiveMethodXRayWasNotCompiled [

	| methodToXray target |
	
	"This test is only valid as far as the method is the same.
	It should be a method with so many literals that the compiler does not even try to compile it."
	target := (SlangBasicTranslationTestClass>>#methodDefiningSingleExternVariable).
	self assert: target bytecodes hash equals: 222697369.
	
	methodToXray := self createMethodOopFromHostMethod: target.
	interpreter push: methodToXray.

	interpreter primitiveMethodXray.

	"Is the second lowest bit turned off"
	self deny: ((memory integerValueOf: interpreter stackTop) anyMask: 2r0010)
]

{ #category : 'accessing' }
VMJITVMPrimitiveTest >> yourself2 [
	^ self 
]
