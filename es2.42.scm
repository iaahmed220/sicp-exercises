(define (queens board-size)
  (define (queen-cols k)
    (if (= k 0)
      (list empty-board)
      (filter
        (lambda (positions) (safe? k positions))
        (flatmap
          (lambda (rest-of-queens)
            (map (lambda (new-row)
                   (adjoin-position new-row k rest-of-queens))
                 (enumerate-interval 1 board-size)))
          (queen-cols (- k 1))))))
  (queen-cols board-size))
; imported from previous exercises
(define (flatmap proc seq)
  (fold-right append (list) (map proc seq)))
(define (enumerate-interval low high)
  (if (> low high)
    (list)
    (cons low (enumerate-interval (+ low 1) high))))
; data structure: single queen
(define (make-queen column row)
  (list column row))
(define (column queen)
  (car queen))
(define (row queen)
  (cadr queen))
; data structure: positions
(define empty-board (list))
(define (rightest-queen positions)
  (car positions))
(define (all-but-last positions)
  (cdr positions))
(define (adjoin-position new-row k rest-of-queens)
  (cons (make-queen k new-row) rest-of-queens))
; presentation
(define (readable queen)
  (display "column: ")
  (display (column queen))
  (display ", row: ")
  (display (row queen))
  (newline))
(define (dump solutions)
  (map (lambda (positions)
         (map readable positions)
         (display "---")
         (newline))
       solutions))
; specific operations
(define (conflict? queen1 queen2)
  (or (= (column queen1)
         (column queen2))
      (= (row queen1)
         (row queen2))
      ; same "principal" diagonal
      (= (- (row queen2) (row queen1))
         (- (column queen2) (column queen1)))
      ; trying out same "other" diagonal
      (= (- (row queen2) (row queen1))
         (- (column queen1) (column queen2)))))
(define (safe? k positions)
  (eq? (list)
       (filter (lambda (queen-in-conflict) (conflict? queen-in-conflict
                                                      (rightest-queen positions)))
               (all-but-last positions))))

