import CDNSSD

extension DNSService {
    // Based on https://github.com/nallick/dns_sd/blob/9e9841c131cc1357fc63b69ff75d6d91e45b8429/Sources/dns_sd/Flags.swift
    // MIT-licensed (Copyright (c) 2019 Purgatory Design)

    struct Flags: OptionSet, Hashable {
        let rawValue: CDNSSD.DNSServiceFlags

        static let moreComing           = Self(rawValue: kDNSServiceFlagsMoreComing)
        static let add                  = Self(rawValue: kDNSServiceFlagsAdd)
        static let `default`            = Self(rawValue: kDNSServiceFlagsDefault)
        static let noAutoRename         = Self(rawValue: kDNSServiceFlagsNoAutoRename)
        static let shared               = Self(rawValue: kDNSServiceFlagsShared)
        static let unique               = Self(rawValue: kDNSServiceFlagsUnique)
        static let browseDomains        = Self(rawValue: kDNSServiceFlagsBrowseDomains)
        static let registrationDomains  = Self(rawValue: kDNSServiceFlagsRegistrationDomains)
        static let longLivedQuery       = Self(rawValue: kDNSServiceFlagsLongLivedQuery)
        static let allowRemoteQuery     = Self(rawValue: kDNSServiceFlagsAllowRemoteQuery)
        static let forceMulticast       = Self(rawValue: kDNSServiceFlagsForceMulticast)
    }
}
