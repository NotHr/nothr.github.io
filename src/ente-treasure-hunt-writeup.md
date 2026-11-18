---
title: "The Ente Treasure Hunt — Write-Up!"
date: "2026-04-07"
slug: ente-treasure-hunt-writeup
description: "How I solved Ente's hunt using metadata, app lock timeouts, and a one-character typo."
---

# The Ente Treasure Hunt — Write-Up!

I was scrolling through Twitter and found this post from Ente. I was really excited about this so I wanted to give it a try.

![Ente Twitter post](/images/ente-treasure-hunt-writeup/01.png)

I opened the link and it redirected me to an album full of rubber ducks, and there was the first clue.

![](/images/ente-treasure-hunt-writeup/02.png)

First clue:

> I am recording this currently from the Ente office. As you can see in the screen already, there are some 1000 duckies in there and each of them hold a location. So your task in this round is to actually find the ducky whose location is the place where I am at right now. So that will lead you to your next clue.

So obviously, my location = Ente office location.

Initially I thought the duck would be in an office environment or in office attire. Then I used the ente’s powerful search and tried searching “office” etc., but no luck.

Then I thought about searching in metadata and found the location on maps.

![](/images/ente-treasure-hunt-writeup/03.png)

I opened my maps, checked the duck’s location in Bengaluru, and verified it with Google Maps

![](/images/ente-treasure-hunt-writeup/04.png)

![](/images/ente-treasure-hunt-writeup/05.png)

and there was the next clue in the description, with a link to an Ente locker. with a link to ente locker link

<https://share.ente.io/F3JZZ3PH7X#XaSQcjoH86sT>

![](/images/ente-treasure-hunt-writeup/06.png)

I was really excited because the hunt creator was making me use all the Ente features. Being an Ente amateur self-hoster and a hardcore fan, this was easy and exciting for me.

Now this time it’s a link to another album with a password. The hints were:

    - It's a set of 6 numbers.

    - It's the longest timeout in the App Lock of Ente Photos, before logging you out.

    - you might want to change the unit

I thought: let’s go through the docs and find out about App Lock.

![](/images/ente-treasure-hunt-writeup/07.png)

My eyes went to Auto Lock because of the numbers: 0, 5s, 15s, 1m, 5m, 30m. I entered all combinations of them: 0, 5, 15, 1, 5, 30. I also converted them to seconds: 0, 5, 15, 60, 300, 1800. I even tried the sum.

Later I realised I was looking at it the wrong way. Auto Lock just locks the app after inactivity (being in the background), and if you have a PIN or biometric set, it simply unlocks the app again.

So I had App Lock set to biometric — I changed it to a PIN-based system and tried entering the wrong PIN multiple times, which triggered the timeout. Then I searched the codebase for App Lock files and found this:

`2^(attemptCount - 5) * 30 * 1000`

After 5 attempts it gives a timeout, with a maximum of 10 attempts:

- 5th wrong attempt: 30s
- 6th: 60s
- 7th: 120s
- 8th: 240s
- 9th: 480s
- 10th: logout

So 480s = 8 minutes is the longest timeout. I tried it (I forgot the 1st hint at first), then remembered they use `ms` — so **480000** — and it unlocked the album.

<https://albums.ente.io/?t=CCSRC5KHX2#By1h8bPUMaYPFLVmM3dA9zAD7WkZz4MD5mJHDf7sETss>

![](/images/ente-treasure-hunt-writeup/08.png)

I saw the “Final Final” title and was happy. The next clue was about the flexible layout, and I was adjusting it to see if anything aligned.

![](/images/ente-treasure-hunt-writeup/09.png)

One link finally matched. I was lazy to extract the text and asked ChatGPT to do it, but it didn’t give the correct result, so I manually typed each character — and got a response saying something went wrong.

<https://albums.ente.io/?t=DMTH3CYTAX#FFC1PtVw8N4nqGNiCj5NXPp1pHnEztsR3NYZeGy472QU>

![](/images/ente-treasure-hunt-writeup/10.png)

I thought there would be something in the network logs and searched through them, but found everything normal. I was about to give up — but then I thought: why not cross-verify again?

And I found the culprit. I had accidentally typed **N** instead of **M**:

<s>`...nqGNiCj5...`</s> → `...nqGMiCj5...`

And voilà — I got the correct album link:

<https://albums.ente.io/?t=DMTH3CYTAX#FFC1PtVw8N4nqGMiCj5NXPp1pHnEztsR3NYZeGy472QU>

![](/images/ente-treasure-hunt-writeup/11.png)

At first I saw it said 10 more albums and felt a little overwhelmed — but I was determined to find the next puzzle.

![](/images/ente-treasure-hunt-writeup/12.png)

I used Google Search for “Ente Himalaya” to search for the blog, and seeing the Himalayas and the 3-letter block, I thought it was **Leh** but was hesitant, so I checked their blog:

<https://ente.com/blog/trips/>

It had an album link to the timeline.

![](/images/ente-treasure-hunt-writeup/13.png)

Damn, I was right! I opened the link:

<https://ente.io/leh>

And got the Ente paste link to the treasure.

![](/images/ente-treasure-hunt-writeup/14.png)

![](/images/ente-treasure-hunt-writeup/15.png)

I was happy that I was the first person to claim it. I truly experienced everything Ente has to offer across its features and products. I loved this!

**P.S.** If this is your first time hearing about Ente, check them out at <https://ente.com> — you won’t regret it!
