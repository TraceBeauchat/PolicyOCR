# README

This README documents the Kin PolicyOCR challenge.  For ease of use, the solution
was developed as a Rails application, however does not define any controllers, 
models, views, etc.  The repository as it stands supports the first three user 
stories.

## User Story 1
Kin has just recently purchased an ingenious machine to assist in reading policy 
report documents. The machine scans the paper documents for policy numbers, and 
produces a file with a number of entries which each look like this:
```
    _  _     _  _  _  _  _ 
  | _| _||_||_ |_   ||_||_|
  ||_  _|  | _||_|  ||_| _|
                           
```
Each entry is 4 lines long, and each line has 27 characters. The first 3 lines 
of each entry contain a policy number written using pipes and underscores, and 
the fourth line is blank. Each policy number should have 9 digits, all of which 
should be in the range 0-9. A normal file contains around 500 entries.

The first task is to write a program that can take this file and parse it into 
actual numbers.

## User Story 2
Having done that, you quickly realize that the ingenious machine is not in fact
infallible. Sometimes it goes wrong in its scanning. So the next step is to 
validate that the numbers you read are in fact valid policy numbers. A valid p
olicy number has a valid checksum. This can be calculated as follows:
```
policy number:   3  4  5  8  8  2  8  6  5 
position names: d9 d8 d7 d6 d5 d4 d3 d2 d1

checksum calculation: (d1+(2*d2)+(3*d3)+...+(9*d9)) mod 11 = 0
```
The second task is to write some code that calculates the checksum for a 
given number, and identifies if it is a valid policy number.

## User Story 3
Your boss is keen to see your results. They ask you to write out a file of 
your findings, one for each input file, in this format:
```
457508000
664371495 ERR 
86110??36 ILL
```
i.e. the file has one policy number per row. If some characters are illegible,
they are replaced by a ?. In the case of a wrong checksum (ERR), or illegible 
number (ILL), this is noted in a second column indicating status.

## The Solution

The first two user stories are implemented in a Service called __PolicyOcr__
and makes use of a class called __PolicyNumber__.  These can be found in:
```ruby
app/classes/policy_number.rb
```
and
```ruby
app/services/policy_ocr.rb
```

__Example:__
```ruby
policy_numbers = PolicyNumber.call(filename:'path-to-file')
```
will attempt to load the file and parse it as a valid policy number OCR file.
If successful, it returns an array of __PolicyNumber__ instances.

The third user story is implemented in a service called __PolicyNumberReport__ 
and allows the writing of the policy number status file. It is located at
```ruby
app/services/policy_number_report.tb
```

__Example__
```ruby
PolicyNumberReport.call(policy_numbers:, filename:'path-to-file')
```
This service will validate the __PolicyNumber__ instances and create the 
file requested.

## Exercising the Solution
The easiest way to play with the services is by starting a _rails_ console:
```ruby
rails console
```
and then by making the calls as illustrated above.

There is a valid OCR text file located at
```ruby
lib/assets/policy_numbers.txt
```
that can be used for initial testing.

* Ruby version: 3.2.2
