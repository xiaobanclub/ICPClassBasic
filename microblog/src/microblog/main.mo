import List "mo:base/List";
import Iter "mo:base/Iter";
import Time "mo:base/Time";
import Principal "mo:base/Principal";

actor {
    type Message = {
        msg: Text;
        time: Time.Time;
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

    public shared func follow(id: Principal): async () {
        followed := List.push(id, followed);
    };

    public shared query func follows(): async [Principal] {
        List.toArray(followed)
    };

    public shared (msg) func post(text: Text): async () {
        assert(Principal.toText(msg.caller) == "tgepg-tkfq4-xlmpw-3ofey-mx2xu-h5sse-g374z-mfvkx-lu6jt-h2axk-fae");

        var now = Time.now();
        let message = {
            msg = text;
            time =  now;
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
