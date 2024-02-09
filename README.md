# the-beast-unite-and-resist

## Preface

In the year 2001, the movie [A.I. Artificial Intelligence](https://www.imdb.com/title/tt0212720/)
was announced.  As part of the marketing effort for the movie, Warner Brothers enlisted Microsoft
to create an [Alternate Reality Game](https://en.wikipedia.org/wiki/Alternate_reality_game)
that became known as [The Beast](https://en.wikipedia.org/wiki/The_Beast_(game)).

Dozens of websites were created, purporting to tell a murder mystery tangential to the movie.
The general public was enlisted to figure out the mystery by solving puzzles and challenges
on the websites, finding more about the story along the way.  There was a large group of individuals
named [Cloudmakers](https://web.archive.org/web/20011018165712/http://www.cloudmakers.org/)
that chatted about the game in yahoo groups and IRC.

One of these websites, [Unite and Resist](http://unite-and-resist.org/) had
[a page](0-997B-1047-1-100-0-A.htm) that required a code to proceed further.

There were multiple groups working on trying to figure out the code by tracking it
down from within the game.  I decided that brute forcing it might be faster, so I wrote
these scripts.  In the end, one of the other teams prevailed.

I thought now might be a good time to release this code, since I just recently rewatched the movie.

There is [an archive](https://web.archive.org/web/20010624120143/http://www.perceive.net/cloudmakers/)
of the home page for this on my website.

## The Code

In this repository you'll find the code that was used for brute forcing.  I was inspired
greatly by the [BOINC](https://boinc.berkeley.edu) distributed computing project.  This code
breaker works in this model, with a server DB that keeps track of the codes that
have been tried, as well as distributes blocks of codes to the clients to try out.  The
code was primarily distributed as a compiled executable for windows machines.  The client
is written in Perl, and the DB backend was MS-SQL.  There was no API layer between the clients
and the DB (Yes, this is terrible, it was the year 2000.)

```
/[0-997B-1047-1-100-0-A.htm](0-997B-1047-1-100-0-A.htm) A sample of the code input HTML page
/stats_overall.htm  :  a snapshot of the statistics page
/1.0  :  Version 1.0, not distributed.
/1.2  :  Version 1.2, the first distributed version
/2.0  :  Version 2.0, Code is lost.
/3.0  :  Version 3.0
/3.1  :  Version 3.1, the final version
/current : In-development code
/sql  :  SQL Scripts for creating the DB
/utilities : reporting and maintenance utilities.
```
