describe "cli", ->
	describe "parameterBuilder", ->
		parameterBuilder = tokenized = undefined
		beforeEach ->
			parameterBuilder = require "./parameterBuilder"
			tokenized = 
				primitives:
					testPrimitiveA: 
						parse: (token) ->
							if token is "Test Literal A"
								false						
					testPrimitiveB: 
						parse: (token) ->
							if token is "Test Literal B"
								"Test Primitive"						
					testPrimitiveC: 
						parse: (token) ->
							if token is "Test Literal C"
								0						
					testPrimitiveD:
						parse: (token) ->
							if token is "Test Literal D"
								null						
					testPrimitiveE:
						parse: (token) ->
							if token is "Test Literal E"
								""										
					testPrimitiveF:
						parse: (token) ->
							if token is "Test Literal F"
								NaN						
							
		it "returns an empty properties object when no parameters are given", ->
			expect parameterBuilder tokenized, []
				.toEqual 
					score: 0
					properties: {}
					
		it "returns a primitive parameter when only a type is given", ->
			expect parameterBuilder tokenized, ["testPrimitiveC"]
				.toEqual 
					score: 1
					parameter:
						type: "testPrimitiveC"
						
		it "returns a primitive constant when only a literal is given for a value of false", ->
			expect parameterBuilder tokenized, ["Test Literal A"]
				.toEqual 
					score: 1
					primitive:
						type: "testPrimitiveA"						
						value: false
						
		it "returns a primitive constant when only a literal is given for a truthy value", ->
			expect parameterBuilder tokenized, ["Test Literal B"]
				.toEqual 
					score: 1
					primitive:
						type: "testPrimitiveB"						
						value: "Test Primitive"
						
		it "returns a primitive constant when only a literal is given for a value of zero", ->
			expect parameterBuilder tokenized, ["Test Literal C"]
				.toEqual 
					score: 1
					primitive:
						type: "testPrimitiveC"						
						value: 0						
						
		it "returns a primitive constant when only a literal is given for a value of null", ->
			expect parameterBuilder tokenized, ["Test Literal D"]
				.toEqual 
					score: 1
					primitive:
						type: "testPrimitiveD"						
						value: null						
						
		it "returns a primitive constant when only a literal is given for a value of \"\"", ->
			expect parameterBuilder tokenized, ["Test Literal E"]
				.toEqual 
					score: 1
					primitive:
						type: "testPrimitiveE"						
						value: ""						
						
		it "returns a primitive constant when only a literal is given for a value of NaN", ->
			expect parameterBuilder tokenized, ["Test Literal F"]
				.toEqual 
					score: 1
					primitive:
						type: "testPrimitiveF"						
						value: NaN						
						
		it "returns a properties object when properties specified", ->
			expect parameterBuilder tokenized, ["a.Test Literal B", "b.testPrimitiveE"]
				.toEqual 
					score: 2
					properties:
						a:
							score: 1
							primitive:
								type: "testPrimitiveB"						
								value: "Test Primitive"						
						b:
							score: 1
							parameter:
								type: "testPrimitiveE"
								
		it "returns a properties object when nested properties are specified", ->
			expect parameterBuilder tokenized, ["a.Test Literal B", "b.testPrimitiveE", "c.nestedA.testPrimitiveF", "c.nestedB.nestedBA.testPrimitiveB", "c.nestedB.nestedBB.Test Literal D"]
				.toEqual 
					score: 5
					properties:
						a:
							score: 1
							primitive:
								type: "testPrimitiveB"						
								value: "Test Primitive"						
						b:
							score: 1
							parameter:
								type: "testPrimitiveE"								
						c:
							score: 3
							properties:
								nestedA:
									score: 1
									parameter:
										type: "testPrimitiveF"
								nestedB:
									score: 2
									properties:
										nestedBA:
											score: 1
											parameter:
												type: "testPrimitiveB"
										nestedBB:
											score: 1
											primitive:
												type: "testPrimitiveD"
												value: null

		it "throws an exception when replacing a root properties object with a root primitive", ->
			expect ->
					parameterBuilder tokenized, ["a.Test Literal B", "b.testPrimitiveE", "Test Literal D"]
				.toThrow
					reason: "parameterDefinedMultipleTimes"
					chain: []
					parameter: "Test Literal D"
		it "throws an exception when replacing a root properties object with a root parameter", ->
			expect ->
					parameterBuilder tokenized, ["a.Test Literal B", "b.testPrimitiveE", "testPrimitiveD"]
				.toThrow
					reason: "parameterDefinedMultipleTimes"
					chain: []
					parameter: "testPrimitiveD"													
		it "throws an exception when replacing a root primitive with properties", ->
			expect ->
					parameterBuilder tokenized, ["Test Literal B", "a.testPrimitiveC"]
				.toThrow
					reason: "parameterDefinedMultipleTimes"
					chain: []
					parameter: "a.testPrimitiveC"													
		it "throws an exception when replacing a root primitive with a root primitive", ->
			expect ->
					parameterBuilder tokenized, ["Test Literal B", "Test Literal C"]
				.toThrow
					reason: "parameterDefinedMultipleTimes"
					chain: []
					parameter: "Test Literal C"										
		it "throws an exception when replacing a root primitive with a root parameter", ->
			expect ->
					parameterBuilder tokenized, ["Test Literal B", "testPrimitiveC"]
				.toThrow
					reason: "parameterDefinedMultipleTimes"
					chain: []
					parameter: "testPrimitiveC"										
		it "throws an exception when replacing a root parameter with properties", ->
			expect ->
					parameterBuilder tokenized, ["testPrimitiveC", "a.testPrimitiveB"]
				.toThrow
					reason: "parameterDefinedMultipleTimes"
					chain: []
					parameter: "a.testPrimitiveB"													
		it "throws an exception when replacing a root parameter with a root primitive", ->
			expect ->
					parameterBuilder tokenized, ["testPrimitiveC", "Test Literal D"]
				.toThrow
					reason: "parameterDefinedMultipleTimes"
					chain: []
					parameter: "Test Literal D"																
		it "throws an exception when replacing a root parameter with a root parameter", ->
			expect ->
					parameterBuilder tokenized, ["testPrimitiveC", "testPrimitiveE"]
				.toThrow
					reason: "parameterDefinedMultipleTimes"
					chain: []
					parameter: "testPrimitiveE"					
		it "throws an exception when replacing a nested properties object with a root primitive", ->
			expect ->
					parameterBuilder tokenized, ["a.b.testPrimitiveC", "Test Literal D"]
				.toThrow
					reason: "parameterDefinedMultipleTimes"
					chain: []
					parameter: "Test Literal D"								
		it "throws an exception when replacing a nested properties object with a root parameter", ->
			expect ->
					parameterBuilder tokenized, ["a.b.testPrimitiveC", "testPrimitiveE"]
				.toThrow
					reason: "parameterDefinedMultipleTimes"
					chain: []
					parameter: "testPrimitiveE"																			
		it "throws an exception when replacing a nested primitive with properties", ->
			expect ->
					parameterBuilder tokenized, ["a.Test Literal C", "a.b.testPrimitiveE"]
				.toThrow
					reason: "parameterDefinedMultipleTimes"
					chain: ["a"]
					parameter: "a.b.testPrimitiveE"						
		it "throws an exception when replacing a nested primitive with a root primitive", ->
			expect ->
					parameterBuilder tokenized, ["a.Test Literal C", "Test Literal E"]
				.toThrow
					reason: "parameterDefinedMultipleTimes"
					chain: []
					parameter: "Test Literal E"									
		it "throws an exception when replacing a nested primitive with a root parameter", ->
			expect ->
					parameterBuilder tokenized, ["a.Test Literal C", "testPrimitiveE"]
				.toThrow
					reason: "parameterDefinedMultipleTimes"
					chain: []
					parameter: "testPrimitiveE"									
		it "throws an exception when replacing a nested primitive with a nested primitive", ->
			expect ->
					parameterBuilder tokenized, ["a.Test Literal C", "a.Test Literal E"]
				.toThrow
					reason: "parameterDefinedMultipleTimes"
					chain: ["a"]
					parameter: "a.Test Literal E"									
		it "throws an exception when replacing a nested primitive with a nested parameter", ->
			expect ->
					parameterBuilder tokenized, ["a.Test Literal C", "a.testPrimitiveE"]
				.toThrow
					reason: "parameterDefinedMultipleTimes"
					chain: ["a"]
					parameter: "a.testPrimitiveE"														
		it "throws an exception when replacing a nested parameter with properties", ->
			expect ->
					parameterBuilder tokenized, ["a.testPrimitiveC", "a.b.testPrimitiveE"]
				.toThrow
					reason: "parameterDefinedMultipleTimes"
					chain: ["a"]
					parameter: "a.b.testPrimitiveE"
		it "throws an exception when replacing a nested parameter with a root primitive", ->
			expect ->
					parameterBuilder tokenized, ["a.testPrimitiveC", "Test Literal D"]
				.toThrow
					reason: "parameterDefinedMultipleTimes"
					chain: []
					parameter: "Test Literal D"			
		it "throws an exception when replacing a nested parameter with a root parameter", ->
			expect ->
					parameterBuilder tokenized, ["a.testPrimitiveC", "testPrimitiveE"]
				.toThrow
					reason: "parameterDefinedMultipleTimes"
					chain: []
					parameter: "testPrimitiveE"							
		it "throws an exception when replacing a nested parameter with a nested primitive", ->
			expect ->
					parameterBuilder tokenized, ["a.testPrimitiveC", "a.Test Literal D"]
				.toThrow
					reason: "parameterDefinedMultipleTimes"
					chain: ["a"]
					parameter: "a.Test Literal D"			
		it "throws an exception when replacing a nested parameter with a nested parameter", ->
			expect ->
					parameterBuilder tokenized, ["a.testPrimitiveC", "a.testPrimitiveE"]
				.toThrow
					reason: "parameterDefinedMultipleTimes"
					chain: ["a"]
					parameter: "a.testPrimitiveE"												
		it "throws an exception when a root primitive literal/name cannot be resolved", ->
			expect ->
					parameterBuilder tokenized, ["Unknown Token"]
				.toThrow
					reason: "primitiveTypeOrLiteralUnrecognized"
					chain: []
					type: "Unknown Token"												
		it "throws an exception when a nested primitive literal/name cannot be resolved", ->
			expect ->
					parameterBuilder tokenized, ["a.Unknown Token"]
				.toThrow
					reason: "primitiveTypeOrLiteralUnrecognized"
					chain: ["a"]
					type: "Unknown Token"																