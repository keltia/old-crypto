///////////////////////////////////////
///	ADFGVX	///
///////////////////////////////////////
//intxt -- Plaintext/ciphertext
//abc -- Base alphabet
//KW1 -- Alphabet square key
//KW2 -- Permutation key
//P1 -- Letters used for the square (generally ADFGVX)
//dir -- E for encrypt, D for decrypt
function ADFGVXen() {
    document.adfgvx.result.value = ADFGVX(document.adfgvx.text.value, document.adfgvx.abc.value, document.adfgvx.KW1.value, document.adfgvx.KW2.value, document.adfgvx.P1.value, "E");
}

function ADFGVXde() {
    document.adfgvx.result.value = ADFGVX(document.adfgvx.text.value, document.adfgvx.abc.value, document.adfgvx.KW1.value, document.adfgvx.KW2.value, document.adfgvx.P1.value, "D");
}

function ADFGVX(intxt, abc, KW1, KW2, P1, dir)
 {
    P1 = P1.toLowerCase();
    intxt = intxt.toLowerCase();
    var i,
    msg = "",
    msglen,
    outtxt = "",
    cdlets = P1;
    intxt = RemoveNonLets(intxt, abc);
    cyabc = MakeCipherABC(abc, KW1);

    KW2sort = DoSortString(KW2);
    PermKW = "";
    for (i = 0; i < KW2.length; i++) {
        PermKW += KW2.indexOf(KW2sort.charAt(i))
    };
    //Make the Permutation
    if (dir == 'E')
    {
        for (i = 0; i < intxt.length; i++) {
            let = intxt.charAt(i);
            pos = cyabc.indexOf(let);
            msg += cdlets.charAt(pos / cdlets.length) + cdlets.charAt(pos % cdlets.length)
        };
        //Grid to edge
        msg = PadToPeriod(msg, 'j', KW2.length);
        msg2 = DoPermute(msg, PermKW, 'E');
        //Permute
        msg3 = "";
        for (j = 0; j < PermKW.length; j++) for (k = 0; k < msg.length; k += PermKW.length) {
            msg3 += msg2.charAt(j + k)
        };
        //Read down the columns
        msg = msg3;
    };


    if (dir == 'D')
    {
        msg3 = "";
        for (k = 0; k < intxt.length; k++) {
            for (j = 0; j < PermKW.length; j++) {
                msg3 += intxt.charAt(j * intxt.length / PermKW.length + k)
            }
        };
        //cols back to rows
        invPerm = "";
        for (i = 0; i < PermKW.length; i++) {
            invPerm += PermKW.indexOf(i)
        };
        PermKW = invPerm;
        msg2 = DoPermute(msg3, PermKW, 'D');
        for (i = 0; i < intxt.length; i += 2) {
            let1 = msg2.charAt(i);
            let2 = msg2.charAt(i + 1);
            pos1 = cdlets.indexOf(let1);
            pos2 = cdlets.indexOf(let2);
            msg += cyabc.charAt(pos1 * cdlets.length + pos2)
        };
    };

    return msg;
};

//Supporting Functions
function RemoveNonLets(x, abc)
 {
    var i,
    chr,
    letinABC = "";
    //x=x.toLowerCase();abc=abc.toLowerCase();
    for (i = 0; i < x.length; i++) {
        chr = x.charAt(i);
        if (abc.indexOf(chr) >= 0) {
            letinABC += chr
        };
    };
    //remove foreign chars
    return letinABC;
};

function MakeCipherABC(abc, KW)
//creates the cipher alphabet by shifting the KW letters to the front
 {
    cyabc = KW + abc;
    //create the cipher-alphabet
    for (i = 0; i < abc.length; i++) {
        let = cyabc.charAt(i);
        pos = cyabc.indexOf(let, i + 1);
        while (pos > -1) {
            cyabc = cyabc.substring(0, pos) + cyabc.substring(pos + 1, cyabc.length);
            pos = cyabc.indexOf(let, i + 1);
        };
    };
    return cyabc;
};

function DoPermute(intxt, permKW, dir)
 {
    var i,
    j,
    per,
    msglen,
    outtxt = "";
    per = permKW.length;
    if (per < 1) {
        return "KW must have 1 or more #'s"
    };
    for (i = 0; i < per; i++) {
        pos = permKW.indexOf(i);
        if (pos < 0) {
            alert("ERROR:  Permutation key does not include all numbers between the min and the max.");
        }
    }
    msglen = intxt.length;
    intxt = PadToPeriod(intxt, '*', per)
    //pad with *'s for now
    permArr = new Array(0);
    for (i = 0; i < per; i++) {
        permArr[i] = eval(permKW.charAt(i))
    };
    //turn it into #'s
    for (j = 0; j < Math.floor(intxt.length / per); j++) {
        for (i = 0; i < per; i++) {
            outtxt += intxt.charAt(per * j + permArr[i]);
        };
    };
    return outtxt;
};

function PadToPeriod(x, padlet, per)
 {
    var i,
    msglen = x.length;
    for (i = 0; i < (per - (msglen % per)) % per; i++) {
        x += padlet
    };
    //pad with *'s for now
    return x;
};

function DoSortString(x)
 {
    var i,
    needmore;
    //John's Patented BB Sort (Bouncing Bubbles)
    //The bouncing
    for (i = 0; i < x.length; i++)
    {
        r1 = Math.random() * x.length;
        r2 = Math.random() * x.length;
        if (r1 == r2) {
            r2 = (r2 + 1) % x.length
        };
        rl = Math.min(r1, r2);
        rg = Math.max(r1, r2);
        let1 = x.charAt(rl);
        let2 = x.charAt(rg);
        if (let1 > let2) {
            x = x.substring(0, rl) + let2 + x.substring(rl + 1, rg) + let1 + x.substring(rg + 1, x.length);
            i = 0;
        };
    };

    //The bubbles
    do {
        needmore = 0;
        for (i = 0; i < x.length - 1; i++)
        {
            let1 = x.charAt(i);
            let2 = x.charAt(i + 1);
            if (let1 > let2) {
                x = x.substring(0, i) + let2 + let1 + x.substring(i + 2, x.length);
                needmore = 1
            };
        };
    }
    while (needmore == 1);

    return x;
};

function MakeKeyedAlphabet(key, alphabet)
 {
    var out = "";
    alphabet = alphabet.toLowerCase();

    if (typeof(key) != 'string')
    return alphabet;

    key = key.toLowerCase() + alphabet;
    for (var i = 0; i < key.length; i++)
    {
        if (out.indexOf(key.charAt(i)) < 0 &&
        alphabet.indexOf(key.charAt(i)) >= 0)
        {
            out += key.charAt(i);
        }
    }

    return out;
}
