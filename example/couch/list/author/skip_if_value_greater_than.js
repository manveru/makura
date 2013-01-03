function (doc, req) {
    //for filtering a reduced function with format [keys, integer]
    provides("json", function() {
        output = [];
        while (row = getRow()) {
            if(row.value > (req.query.val || 1)) output.push( {"key": row.key, "value": row.value} );
        }
        send(JSON.stringify(output));
    });
}