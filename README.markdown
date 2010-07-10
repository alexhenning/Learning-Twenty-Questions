Learning Twenty Questions
=========================

An implementation of twenty questions in common lisp that learns from user input. The code traversed down a binary tree, asking questions as it goes. Once it reaches a leaf, it makes it's guess. When the question is wrong it asks the user for the correct answer and an identifying question.

Example Usage
-------------
	CL-USER> (load "twenty-questions.cl")
	CL-USER> (run)
	Think of something and I will ask questions till I can guess what you are thinking of.
	Is it organic? yes
	Is it an animal? yes
	Is it a bird? no
	Are you thinking of a Leopard? no
	What where you thinking of? Pony
	What is a question that differenciates what you were thinking of? (Please have the question be as broad as possible) Is it a method of transportation?
	Is it a method of transportation? yes
	NIL
	CL-USER> (run)
	Think of something and I will ask questions till I can guess what you are thinking of.
	Is it organic? yes
	Is it an animal? yes
	Is it a bird? no
	Is it a method of transportation? yes
	Are you thinking of a Pony? no
	What where you thinking of? Elephant
	What is a question that differenciates what you were thinking of? (Please have the question be as broad as possible) Is it big?
	Is it big? yes
	NIL