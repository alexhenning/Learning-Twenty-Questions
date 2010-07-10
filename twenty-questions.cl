;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; AUTO LEARNING TWENTY QUESTIONS
;; Author: Alex Henning
;; License: WTFPL
;; Description: A version of twenty questions that starts put very dumb and
;;              learns from the users. The learnt items will then persist
;;              between games.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(defparameter *question-tree* nil)
(defparameter *tree-modified-p* nil)
(defparameter *trace* nil)

(defclass tree ()
  ;; A class that stores a question and a yes and no branch.
  ;; It is used to form a binary tree that is traversed to guess what the
  ;; user is thinking of.
  ((question :initarg :question)
   (yes :initarg :yes)
   (no :initarg :no)))
(defmethod print-object ((object tree) stream)
  (with-slots (question yes no) object
    (format stream "~s" `(make-tree ,question ,yes ,no))))
(defun make-tree (question yes no)
  (make-instance 'tree :question question :yes yes :no no))

(defclass leaf ()
  ;; A leaf stores the value of what the user is(should be) thinking of.
  ((value :initarg :value)))
(defmethod print-object ((object leaf) stream)
  (with-slots (value) object
    (format stream "~s" `(make-leaf ,value))))
(defun make-leaf (value)
  (make-instance 'leaf :value value))

(defun run (&optional file)
  "The main function used to run a game of twenty questions with a text UI"
  (unless file (setf file "twenty-questions.brain"))
  (let ((*question-tree* (load-question-tree file))
	(*tree-modified-p* nil)
	(*trace* nil))
    (format t "Think of something and I will ask questions till I can guess what you are thinking of.") (fresh-line)
    (handle-node *question-tree*)
    (when *tree-modified-p*
      (save-question-tree file))))

(defgeneric handle-node (node)
	   (:documentation  "Handle the processing of the node, asking for
                             user input as relevant to keep the game going"))
(defmethod handle-node ((node tree))
  (with-slots (question yes no) node
    (let ((response (yes-or-no-prompt question)))
      (push response *trace*)
      (handle-node (if (eq 'yes response) yes no)))))
(defmethod handle-node ((node leaf))
  (with-slots (value) node
    (format t "Are you thinking of a ~a?" value)
    (if (eq 'yes (yes-or-no-prompt ""))
	(format  t "You are thinking of a ~a!" value)
	(fix-tree node))))

(defun fix-tree (node)
  "Add a new item to the tree when the user thinks of something the tree
   doesn't already know"
  (let* ((wrong-branch (trace-tree *question-tree* (butlast (reverse *trace*))))
	 (new-leaf (make-leaf (prompt "What where you thinking of?")))
	 ;; TODO: customize based off of input
	 (question (make-tree (prompt "What is a question that differenciates what you were thinking of? (Please have the question be as broad as possible)") nil nil))
	 (branch (yes-or-no-prompt (slot-value question 'question))))
    (setf (slot-value question branch) new-leaf)
    (setf (slot-value question
		      (if (eq 'yes branch) 'no 'yes)) node)
    (setf (slot-value wrong-branch (first *trace*)) question)
    (setf *tree-modified-p* t)))
(defun trace-tree (tree trace-list)
  (if (not (null trace-list))
      (trace-tree (slot-value tree (first trace-list))
		  (rest trace-list))
      tree))
  
(defun prompt (prompt)
  (format t "~a " prompt)
  (read-line))
(defun yes-or-no-prompt (text)
  (if (string-equal (prompt text) "yes")
      'yes
      'no))

(defun load-question-tree (file)
  "Loads the question tree, except when the file doesn't exist in which case
   it creates a new tree"
  (if (probe-file file)
      (with-open-file (in file)
	(setf *question-tree* (eval (read in))))
      (build-base-tree)))
(defun save-question-tree (file)
  (with-open-file (out file
		       :direction :output
		       :if-exists :overwrite
		       :if-does-not-exist :create)
    (format out "~s" *question-tree*)))

(defun  build-base-tree ()
  (make-tree "Is it organic?"
	     (make-tree "Is it an animal?"
			(make-tree "Is it a bird?"
				   (make-leaf "Penguin")
				   (make-leaf "Leopard"))
			(make-leaf "Tree"))
	     (make-tree "Is it bigger than a breadbox?"
			(make-leaf "Robot")
			(make-leaf "Toaster"))))