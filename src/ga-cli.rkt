#lang racket

;; Standalone command-line interface for the GA144 aForth toolchain.
;; This deliberately depends only on Racket modules.

(require racket/cmdline
         racket/path
         racket/runtime-path
         "compile.rkt"
         "assemble.rkt"
         "bootstream.rkt"
         "ga-compile-print.rkt"
         "interpreter.rkt")

(define-runtime-path project-root "..")

(define bootstream-type "async")
(define include-bootstream? #f)
(define only-bootstream? #f)
(define symbols? #f)
(define pretty? #f)
(define count? #f)
(define hex? #f)
(define run? #f)
(define test? #f)
(define test-all? #f)
(define source-file #f)

(define (fail message . args)
  (apply eprintf (string-append "ga: " message "\n") args)
  (exit 1))

(define (run-file filename)
  (define chip (new-ga144 "cli"))
  (load-file chip filename)
  (send chip step-program!*))

(define (print-only-bootstream filename)
  (define compiled (aforth-compile-file filename))
  (define bytes
    (sget-convert (make-bootstream (assemble compiled) bootstream-type)))
  (displayln (string-join (map number->string bytes) " ")))

(command-line
 #:program "ga"
 #:once-each
 [("-b" "--bootstream") "include a loadable bootstream in JSON output"
                         (set! include-bootstream? #t)]
 [("--bootstream-type") type "bootstream type: async, 2wire, or async-target"
                          (set! bootstream-type type)]
 [("--only-bootstream") "print only the serial-loadable bootstream bytes"
                           (set! only-bootstream? #t)]
 [("-s" "--symbols") "include the symbol table in JSON output"
                       (set! symbols? #t)]
 [("-p" "--pretty") "print human-readable compiled and assembled output"
                      (set! pretty? #t)]
 [("-c" "--count") "print RAM usage by node" (set! count? #t)]
 [("-x" "--hex") "render numbers in hexadecimal when used with --pretty"
                   (set! hex? #t)]
 [("-r" "--run") "run the program in the non-interactive simulator"
                    (set! run? #t)]
 [("-t" "--test") "run compiler tests" (set! test? #t)]
 [("-T" "--test-all") "run compiler and simulator tests"
                        (set! test? #t) (set! test-all? #t)]
 #:args files
 (cond [(or test? test-all?)
        (unless (null? files)
          (fail "tests do not accept a source file"))]
       [(not (= (length files) 1))
        (fail "expected one aForth source file; run `ga --help` for usage")]
       [else (set! source-file (car files))]))

(when (or test? test-all?)
  ;; These modules execute their test suites when loaded in Racket mode.
  (dynamic-require (build-path project-root "tests" "test-compiler.rkt") #f)
  (when test-all?
    (dynamic-require (build-path project-root "tests" "tests.rkt") #f))
  (exit 0))

(unless (file-exists? source-file)
  (fail "file does not exist: ~a" source-file))

(cond [only-bootstream? (print-only-bootstream source-file)]
      [run? (run-file source-file)]
      [count? (print-count source-file)]
      [pretty? (print-pretty source-file (lambda () hex?))]
      [else
       ;; Preserve the original CLI's default: JSON with a bootstream.
       (print-json source-file
                   (and (or include-bootstream? #t)
                        (lambda () bootstream-type))
                   (lambda () symbols?))])
