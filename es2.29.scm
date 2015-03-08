(define (make-mobile left right)
  (list left right))
(define (make-branch length structure)
  (list length structure))
(define (left-branch mobile)
  (car mobile))
(define (right-branch mobile)
  (car (cdr mobile)))
(define (branch-length branch)
  (car branch))
(define (branch-structure branch)
  (car (cdr branch)))
(define (is-mobile? maybe-mobile)
  (pair? maybe-mobile))
(define (total-weight-branch branch)
  (let ((structure (branch-structure branch)))
    (if (is-mobile? structure)
        (total-weight structure)
        structure)))
(define (total-weight mobile)
  (+ (total-weight-branch (left-branch mobile))
     (total-weight-branch (right-branch mobile))))

(define my-mobile (make-mobile (make-branch 10 5)
                               (make-branch 10 (make-mobile (make-branch 2 3)
                                                            (make-branch 2 2)))))

