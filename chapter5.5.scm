(load "es4.5.scm")
(load "es4.13.scm")
(load "es4.22.scm")
(load "chapter5.2.scm")
(load "chapter5.scm")
(define (compile exp target linkage)
  (cond ((self-evaluating? exp)
		 (compile-self-evaluating exp target linkage))
		((quoted? exp) (compile-quoted exp target linkage))
		((variable? exp)
		 (compile-variable exp target linkage))
		((assignment? exp)
		 (compile-assignment exp target linkage))
		((definition? exp)
		 (compile-definition exp target linkage))
		((if? exp) (compile-if exp target linkage))
		((lambda? exp) (compile-lambda exp target linkage))
		((begin? exp)
		 (compile-sequence (begin-actions exp)
						   target
						   linkage))
		((cond? exp) (compile (cond->if exp) target linkage))
		((application? exp)
		 (compile-application exp target linkage))
		(else
		  (error "Unknown expression type -- COMPILE" exp))))
; append-instruction-sequence: just appends together
; preserving: appends seq1 and seq2 but wraps around seq1 stack save/restore operations for the registers used by seq2
(define (make-instruction-sequence needs modifies statements)
  (list needs modifies statements))
(define (empty-instruction-sequence)
  (make-instruction-sequence '() '() '()))
