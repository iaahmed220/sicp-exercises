(load "chapter5.2.scm")
(define (make-breakpoint label n)
  (list 'breakpoint label n))
(define (breakpoint-triggers? breakpoint label n)
  (let ((breakpoint-label (cadr breakpoint))
        (breakpoint-n (caddr breakpoint)))
    (and (eq? label breakpoint-label)
         (eq? n breakpoint-n))))
; we start from version of 5.17 which already parses labels
(define (make-new-machine)
  (let ((pc (make-register 'pc))
        (flag (make-register 'flag))
        (stack (make-stack))
        (the-instruction-sequence '())
        (instruction-tracing #f)
        (breakpoints '())
        (last-label 'not-existing-reserved-label)
        (delta-from-label 0))
    (let ((the-ops
            (list (list 'initialize-stack
                        (lambda () (stack 'initialize)))
                  (list 'print-stack-statistics
                        (lambda () (stack 'print-statistics)))))
          (register-table
            (list (list 'pc pc) (list 'flag flag))))
      (define (allocate-register name)
        (if (assoc name register-table)
          (error "Multiply defined register: " name)
          (set! register-table
            (cons (list name (make-register name))
                  register-table)))
        'register-allocated)
      (define (lookup-register name)
        (let ((val (assoc name register-table)))
          (if val
            (cadr val)
            (error "Unknown register:" name))))
      (define (breakpoint)
        (> (length (filter (lambda (candidate)
                             (breakpoint-triggers? candidate last-label delta-from-label))
                           breakpoints))
           0))
      (define (execute)
        (define (inst-text inst)
          (car inst))
        (let ((insts (get-contents pc)))
          (if (null? insts)
            'done
            (begin
              (if (label-exp? (inst-text (car insts)))
                  (begin (set! last-label (label-exp-label (inst-text (car insts))))
                         (set! delta-from-label 0))
                  (set! delta-from-label (+ delta-from-label 1)))
              ; check if there is a breakpoint which corresponds to 
              ; last-label and delta-from-label
              (if (breakpoint)
                  (begin (display last-label)
                         (newline)
                         (display delta-from-label)
                         (newline)
                         'breakpoint)
                  (begin ((instruction-execution-proc (car insts)))
                         (execute)))))))
      (define (proceed)
        (let ((insts (get-contents pc)))
          (begin ((instruction-execution-proc (car insts)))
                 (execute))))
      (define (dispatch message)
        (cond ((eq? message 'start)
               (set-contents! pc the-instruction-sequence)
               (execute))
              ((eq? message 'proceed)
               (proceed))
              ((eq? message 'install-instruction-sequence)
               (lambda (seq) (set! the-instruction-sequence seq)))
              ((eq? message 'allocate-register) allocate-register)
              ((eq? message 'get-register) lookup-register)
              ((eq? message 'install-operations)
               (lambda (ops) (set! the-ops (append the-ops ops))))
              ((eq? message 'stack) stack)
              ((eq? message 'operations) the-ops)
              ((eq? message 'set-breakpoint)
               (lambda (label n)
                 (set! breakpoints
                       (cons (make-breakpoint label n)
                             breakpoints))))
              ((eq? message 'cancel-all-breakpoints)
               (set! breakpoints '()))
              (else (error "Unknown request -- MACHINE" message))))
      dispatch)))
(define (extract-labels text receive)
  (if (null? text)
    (receive '() '())
    (extract-labels (cdr text)
                    (lambda (insts labels)
                      (let ((next-inst (car text)))
                        (if (symbol? next-inst)
                          (let ((fake-label-instruction (list (list 'label
                                                                    next-inst)
                                                              next-inst)))
                            (let ((new-insts (cons fake-label-instruction
                                                   insts)))
                                (receive new-insts
                                         (cons (make-label-entry next-inst
                                                                 new-insts)
                                               labels))))
                          (receive (cons (make-instruction next-inst)
                                         insts)
                                   labels)))))))
(define (make-execution-procedure inst labels machine
                                  pc flag stack ops)
  (cond ((eq? (car inst) 'label)
         (make-label pc))
        ((eq? (car inst) 'assign)
         (make-assign inst machine labels ops pc))
        ((eq? (car inst) 'test)
         (make-test inst machine labels ops flag pc))
        ((eq? (car inst) 'branch)
         (make-branch inst machine labels flag pc))
        ((eq? (car inst) 'goto)
         (make-goto inst machine labels pc))
        ((eq? (car inst) 'save)
         (make-save inst machine stack pc))
        ((eq? (car inst) 'restore)
         (make-restore inst machine stack pc))
        ((eq? (car inst) 'perform)
         (make-perform inst machine labels ops pc))
        (else (error "Unknown instruction type -- ASSEMBLE"
                     inst))))
(define (make-label pc)
  (lambda ()
    (advance-pc pc)))
(define (set-breakpoint machine label n)
  ((machine 'set-breakpoint) label n))
(define (proceed-machine machine)
  (machine 'proceed))
(define (cancel-all-breakpoints machine)
  (machine 'cancel-all-breakpoints))
; inputs
(define factorial-controller
  '((assign continue (label fact-done))
    fact-loop
      (test (op =) (reg n) (const 1))
      (branch (label base-case))
      (save continue)
      (save n)
      (assign n (op -) (reg n) (const 1))
      (assign continue (label after-fact))
      (goto (label fact-loop))
    after-fact
      (restore n)
      (restore continue)
      (assign val (op *) (reg n) (reg val))
      ; val now contains n(n - 1)!
      (goto (reg continue))
    ; return to caller
    base-case
    (assign val (const 1))
    ; base case: 1! = 1
    (goto (reg continue))
    ; return to caller
    fact-done))
(define factorial-machine (make-machine '(n val continue)
                                        (list (list '= =)
                                              (list '- -)
                                              (list '* *))
                                        factorial-controller))


(set-breakpoint factorial-machine 'base-case 2)
(set-register-contents! factorial-machine 'n 6)
(display "Will stop at the breakpoint: ")
(newline)
(start factorial-machine)
(display "Factorial is multipled by 10")
(newline)
(set-register-contents! factorial-machine 'val 10)
(proceed-machine factorial-machine)
(display (get-register-contents factorial-machine 'val))
(newline)
(display "Canceling breakpoints leads to new uninterrupted executions")
(newline)
(cancel-all-breakpoints factorial-machine)
(set-register-contents! factorial-machine 'n 5)
(start factorial-machine)
(display (get-register-contents factorial-machine 'val))
(newline)
