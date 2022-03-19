import List "mo:base/List";
import Iter "mo:base/Iter";
import Time "mo:base/Time";
import Principal "mo:base/Principal";

actor {
    type Message = {
        text: Text;
        time: Time.Time;
        author: Text;
    };

    public type Microblog = actor {
        follow: shared(Principal) -> async ();
        follows: shared query() -> async [Principal];
        post: shared(Text) -> async ();
        posts: shared query(Time.Time) -> async [Message];
        timeline: shared (Time.Time) -> async [Message];
    };

    stable var followed: List.List<Principal> = List.nil();
    stable var messages: List.List<Message> = List.nil();

    stable var cname: Text = "xxx";

    public shared func set_name(opt: Text, name: Text) {
        assert(opt == "pwd");
        cname := name;
    };

    public shared func get_name() : async ?Text {
        return ?cname;
    };

    public shared func follow(id: Principal): async () {
        followed := List.push(id, followed);
    };

    public shared query func follows(): async [Principal] {
        List.toArray(followed)
    };

    public shared (msg) func post(opt: Text, text: Text): async () {
        assert(opt == "pwd");

        var now = Time.now();
        let message = {
            text = text;
            time = now;
            author = cname;
        };

        messages := List.push(message, messages);
    };

    public shared query func posts(since: Time.Time): async [Message] {
        var output : List.List<Message> = List.nil();
        for (msg in Iter.fromList(messages)) {
            if (msg.time >= since) {
                output := List.push(msg, output);
            };
        };

        List.toArray(output)
    };

    public shared func timeline(since: Time.Time): async [Message] {
        var all: List.List<Message> = List.nil();

        for (id in Iter.fromList(followed)) {
            let canister: Microblog = actor(Principal.toText(id));
            let msgs = await canister.posts(since);
            for (msg in Iter.fromArray(msgs)) {
                all := List.push(msg, all);
            };
        };

        List.toArray(all)
    };
};
