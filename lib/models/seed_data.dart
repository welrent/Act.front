import 'contract.dart';
import 'page.dart';

class SeedData {
  static final List<PageItem> pages = [
    PageItem(
      id: 1,
      title: 'Car Rental Agreement',
      slug: 'car-rental-agreement',
      content: '''<article class="legal-document">

<h1>Car Rental Agreement</h1>
<p class="legal-meta">
  <strong>Welrent AutoVerhuur</strong><br>
  [COMPANY_ADDRESS]<br>
  Chamber of Commerce: [CHAMBER_OF_COMMERCE_NUMBER]<br>
  VAT Number: [VAT_NUMBER]<br>
  Email: <a href="mailto:[EMAIL]">[EMAIL]</a> &nbsp;|&nbsp; Phone: [PHONE_NUMBER]<br>
  <em>Last updated: 2025</em>
</p>

<hr>

<h2>Article 1 – Parties & Definitions</h2>
<p><strong>Lessor:</strong> Welrent AutoVerhuur, registered at [COMPANY_ADDRESS], Chamber of Commerce [CHAMBER_OF_COMMERCE_NUMBER].<br>
<strong>Renter:</strong> The individual or legal entity who enters into this agreement and accepts all terms herein.<br>
<strong>Authorised Driver:</strong> Any person listed on this agreement who is permitted to operate the Vehicle.<br>
<strong>Vehicle:</strong> The motor vehicle described in the booking confirmation provided to the Renter.<br>
<strong>Rental Period:</strong> The period commencing at vehicle handover and ending upon confirmed return to Welrent AutoVerhuur.</p>

<h2>Article 2 – Identity & Driving Licence Verification</h2>
<p>The Renter and all Authorised Drivers must present, at the time of vehicle collection:</p>
<ul>
  <li>A valid government-issued photo identification (passport, national ID card or equivalent).</li>
  <li>A valid full driving licence, held for a minimum of 2 years, appropriate for the category of vehicle rented.</li>
  <li>For non-EU licences: an International Driving Permit (IDP) is required.</li>
</ul>
<p>Welrent AutoVerhuur reserves the right to refuse rental if identification or licence cannot be verified to its satisfaction. The minimum age for renting a vehicle is <strong>21 years</strong>. Renters aged 21–24 are subject to a Young Driver Surcharge as stated in the booking confirmation.</p>

<h2>Article 3 – Permitted & Prohibited Use</h2>
<p>The Vehicle may only be used:</p>
<ul>
  <li>On public roads in the Netherlands and within agreed European territory (if applicable).</li>
  <li>In accordance with all applicable Dutch and European traffic laws.</li>
  <li>By the Authorised Driver(s) named in this agreement only.</li>
</ul>
<p>The following uses are strictly <strong>prohibited</strong>:</p>
<ul>
  <li>Commercial transportation of passengers or goods for reward.</li>
  <li>Racing, rally driving, or participation in any motor sport.</li>
  <li>Off-road or unpaved road driving.</li>
  <li>Towing, pushing, or pulling any vehicle or trailer without prior written consent.</li>
  <li>Operating the Vehicle under the influence of alcohol, drugs, or any substance that impairs judgement.</li>
  <li>Transporting hazardous, flammable, or illegal substances or goods.</li>
  <li>Smoking inside the Vehicle.</li>
  <li>Transporting animals without prior written consent.</li>
  <li>Subletting or lending the Vehicle to any third party.</li>
  <li>Driving outside agreed geographic boundaries without prior written authorisation.</li>
</ul>

<h2>Article 4 – Mileage Policy</h2>
<p>The rental includes the mileage allowance stated in the booking confirmation. Excess kilometres are charged at the rate specified therein. Odometer tampering is a criminal offence and will result in immediate termination of the rental agreement and full legal liability being assigned to the Renter. Unlimited mileage options, where available, must be selected at the time of booking.</p>

<h2>Article 5 – Fuel Policy</h2>
<p>The Vehicle is delivered with a <strong>full fuel tank</strong> and must be returned with a full tank of the correct fuel type. Failure to return the vehicle with a full tank will result in:</p>
<ul>
  <li>A fuel service charge (as stated in the booking confirmation).</li>
  <li>The cost of the missing fuel, calculated at the prevailing pump price plus a handling fee.</li>
</ul>
<p>Misfuelling (using the wrong fuel type) is not covered by insurance. All costs resulting from misfuelling are the sole responsibility of the Renter.</p>

<h2>Article 6 – Security Deposit</h2>
<p>A security deposit as specified in the booking confirmation is required at vehicle collection, payable by credit card. Debit cards may not be accepted for deposit purposes. The deposit covers potential charges including, but not limited to: damage, fuel shortfall, late return, fines, and cleaning fees. The deposit will be released within <strong>7 business days</strong> of the Vehicle being returned in compliance with all conditions, subject to inspection. Welrent AutoVerhuur reserves the right to retain all or part of the deposit where applicable charges arise.</p>

<h2>Article 7 – Insurance Coverage</h2>
<p>The Vehicle is covered by the following as standard:</p>
<ul>
  <li><strong>Third-Party Liability (WA):</strong> As required by Dutch law (WAM).</li>
  <li><strong>Basic Collision Damage Waiver (CDW):</strong> Reduces Renter's liability to the excess amount stated in the booking.</li>
</ul>
<p>The following optional upgrades may be purchased:</p>
<ul>
  <li><strong>Super CDW / Zero Excess:</strong> Reduces Renter's excess liability to €0.</li>
  <li><strong>Tyre & Glass Protection.</strong></li>
  <li><strong>Personal Accident Insurance (PAI).</strong></li>
</ul>

<h2>Article 8 – Damage Reporting & Assessment</h2>
<p>A condition inspection is conducted at both vehicle handover and return. The Renter must:</p>
<ul>
  <li>Inspect and sign the condition report at collection, noting any pre-existing damage.</li>
  <li>Report any damage, accident, or theft <strong>immediately</strong> by phone to Welrent AutoVerhuur.</li>
  <li>In the event of an accident involving third parties: obtain the other party's details, call Dutch police (112), and complete an accident report (European Accident Statement).</li>
</ul>

<h2>Article 9 – Late Return & Penalties</h2>
<p>The Vehicle must be returned by the exact date and time stated in the booking confirmation. Returns after the agreed time will be charged accordingly.</p>

<h2>Article 10 – Governing Law & Dispute Resolution</h2>
<p>This agreement is governed exclusively by the laws of the Netherlands. In the event of a dispute, the parties shall first attempt resolution by direct negotiation. Failing this, disputes shall be submitted to the competent court of the district where Welrent AutoVerhuur is registered.</p>

</article>''',
    ),
    PageItem(
      id: 2,
      title: 'Motorcycle Rental Agreement',
      slug: 'motorcycle-rental-agreement',
      content: '''<article class="legal-document">

<h1>Motorcycle Rental Agreement</h1>
<p class="legal-meta">
  <strong>Welrent AutoVerhuur</strong><br>
  [COMPANY_ADDRESS]<br>
  Chamber of Commerce: [CHAMBER_OF_COMMERCE_NUMBER]<br>
  VAT Number: [VAT_NUMBER]<br>
  Email: <a href="mailto:[EMAIL]">[EMAIL]</a> &nbsp;|&nbsp; Phone: [PHONE_NUMBER]<br>
  <em>Last updated: 2026</em>
</p>

<hr>

<h2>Article 1 – Parties & Definitions</h2>
<p><strong>Lessor:</strong> Welrent AutoVerhuur, registered at [COMPANY_ADDRESS].<br>
<strong>Renter:</strong> The individual who enters into this motorcycle or scooter rental agreement.<br>
<strong>Motorcycle:</strong> The two-wheeled motor vehicle described in the booking confirmation, including scooters where applicable.<br>
<strong>Rental Period:</strong> The period from handover until confirmed return of the Motorcycle.</p>

<h2>Article 2 – Licence & Age Requirements</h2>
<ul>
  <li>A valid category A / A1 / A2 (or Dutch equivalent) driving licence is required for the Motorcycle class rented.</li>
  <li>Minimum age is <strong>21 years</strong> unless otherwise stated for light scooters.</li>
  <li>An International Driving Permit is required for non-EU licences.</li>
</ul>

<h2>Article 3 – Safety Equipment</h2>
<p>A certified helmet must be worn at all times while riding. Additional protective gear (jacket, gloves) is strongly recommended. Passengers, where permitted, must also wear a helmet.</p>

<h2>Article 4 – Permitted & Prohibited Use</h2>
<p>The Motorcycle may only be used on public roads within the agreed territory and by the named Renter. Racing, off-road use, towing, stunt riding, and riding under the influence of alcohol or drugs are strictly prohibited.</p>

<h2>Article 5 – Insurance & Deposit</h2>
<p>Third-party liability and basic collision cover apply as stated in the booking. A security deposit is required at collection and released within <strong>7 business days</strong> after compliant return.</p>

<h2>Article 6 – Damage, Theft & Return</h2>
<p>Damage and theft must be reported immediately. The Motorcycle must be returned on time, with the agreed fuel level, and locked with the provided security devices.</p>

<h2>Article 7 – Governing Law</h2>
<p>This agreement is governed by Dutch law. Standard Welrent Act terms for motor vehicle rentals apply where not superseded above.</p>

</article>''',
    ),
    PageItem(
      id: 3,
      title: 'Boat Rental Agreement',
      slug: 'boat-rental-agreement',
      content: '''<article class="legal-document">

<h1>Boat Rental Agreement</h1>
<p class="legal-meta">
  <strong>Welrent AutoVerhuur</strong><br>
  [COMPANY_ADDRESS]<br>
  Chamber of Commerce: [CHAMBER_OF_COMMERCE_NUMBER]<br>
  VAT Number: [VAT_NUMBER]<br>
  Email: <a href="mailto:[EMAIL]">[EMAIL]</a> &nbsp;|&nbsp; Phone: [PHONE_NUMBER]<br>
  <em>Last updated: 2025</em>
</p>

<hr>

<h2>Article 1 – Parties & Definitions</h2>
<p><strong>Lessor:</strong> Welrent AutoVerhuur, registered at [COMPANY_ADDRESS].<br>
<strong>Renter:</strong> The individual or legal entity entering into this boat rental agreement.<br>
<strong>Vessel:</strong> The watercraft provided by Welrent AutoVerhuur as described in the booking confirmation.<br>
<strong>Skipper:</strong> The authorised person responsible for operating the Vessel during the rental period.<br>
<strong>Rental Period:</strong> The agreed period commencing at vessel handover and ending upon confirmed return.</p>

<h2>Article 2 – Identity & Licence Verification</h2>
<p>The Renter and Skipper must present at handover:</p>
<ul>
  <li>A valid government-issued photo ID.</li>
  <li>A valid boating licence (Klein Vaarbewijs I/II, CWO, or recognised equivalent) where required by Dutch law for the specific vessel.</li>
</ul>

<h2>Article 3 – Safety Rules & Obligations</h2>
<ul>
  <li>Life jackets must be available on board for every passenger and worn by children under 12.</li>
  <li>Maximum passenger capacity stated on the Vessel must never be exceeded.</li>
  <li>Navigation lights must be used after dusk and in poor visibility.</li>
</ul>

<h2>Article 4 – Governing Law</h2>
<p>This agreement is governed by Dutch law, including the Binnenvaartpolitiereglement (BPR).</p>

</article>''',
    ),
    PageItem(
      id: 4,
      title: 'Equipment Rental Agreement',
      slug: 'equipment-rental-agreement',
      content: '''<article class="legal-document">

<h1>Equipment Rental Agreement</h1>
<p class="legal-meta">
  <strong>Welrent AutoVerhuur</strong><br>
  [COMPANY_ADDRESS]<br>
  Chamber of Commerce: [CHAMBER_OF_COMMERCE_NUMBER]<br>
  VAT Number: [VAT_NUMBER]<br>
  Email: <a href="mailto:[EMAIL]">[EMAIL]</a> &nbsp;|&nbsp; Phone: [PHONE_NUMBER]<br>
  <em>Last updated: 2025</em>
</p>

<hr>

<h2>Article 1 – Parties & Definitions</h2>
<p><strong>Lessor:</strong> Welrent AutoVerhuur, registered at [COMPANY_ADDRESS].<br>
<strong>Renter:</strong> The individual or legal entity that rents equipment under this agreement.<br>
<strong>Equipment:</strong> The tools, machinery, devices, or other items described in the booking confirmation.<br>
<strong>Rental Period:</strong> The agreed period from collection or delivery until confirmed return of all Equipment.</p>

<h2>Article 2 – Identity Verification</h2>
<p>The Renter must present a valid government-issued photo ID at the time of collection.</p>

<h2>Article 3 – Permitted Use</h2>
<p>The Equipment may only be used for its intended purpose by qualified operators in compliance with Arbowet regulations.</p>

<h2>Article 4 – Governing Law</h2>
<p>This agreement is governed by Dutch law.</p>

</article>''',
    ),
    PageItem(
      id: 5,
      title: 'Terms of Service',
      slug: 'terms',
      content: '''<h1>Terms of Service</h1>
<p><strong>Welrent AutoVerhuur</strong><br>
[COMPANY_ADDRESS]<br>
Chamber of Commerce: [CHAMBER_OF_COMMERCE_NUMBER]<br>
VAT: [VAT_NUMBER]<br>
Email: [EMAIL] | Phone: [PHONE_NUMBER]<br>
<em>Last updated: 2025</em></p>

<hr>

<h2>1. Acceptance of Terms</h2>
<p>By accessing or using the Welrent AutoVerhuur platform ("Service"), you agree to be bound by these Terms of Service. If you do not agree to these terms, you may not use the Service.</p>

<h2>2. Account Registration</h2>
<p>To access certain features, you must create an account. You agree to provide accurate and complete information during registration and to keep your credentials secure.</p>

<h2>3. Payment Conditions</h2>
<p>All prices are listed in Euros (EUR) and include applicable VAT unless stated otherwise. Payment is due at the time of booking or at vehicle/equipment collection, as specified.</p>

<h2>4. Prohibited Use</h2>
<ul>
  <li>Engage in any unlawful, fraudulent, or harmful activity.</li>
  <li>Impersonate any person or entity.</li>
  <li>Attempt to gain unauthorised access to our systems.</li>
  <li>Sublease or resell any rented vehicle, vessel, or equipment.</li>
</ul>

<h2>5. Intellectual Property</h2>
<p>All content on this platform, including text, logos, images, and software, is the property of Welrent AutoVerhuur and is protected by Dutch and international intellectual property laws.</p>

<h2>6. Governing Law</h2>
<p>These Terms are governed by and construed in accordance with the laws of the Netherlands.</p>''',
    ),
    PageItem(
      id: 6,
      title: 'Privacy Policy',
      slug: 'privacy',
      content: '''<h1>Privacy Policy</h1>
<p><strong>Welrent AutoVerhuur</strong><br>
[COMPANY_ADDRESS]<br>
Email: [EMAIL]<br>
<em>Last updated: 2025</em></p>

<hr>

<h2>1. Introduction</h2>
<p>Welrent AutoVerhuur ("we", "us", "our") is committed to protecting your personal data. This Privacy Policy explains how we collect, use, and protect your information in accordance with the General Data Protection Regulation (GDPR) and the Dutch Implementation Act (UAVG).</p>

<h2>2. Data We Collect</h2>
<ul>
  <li><strong>Identity data:</strong> Name, date of birth, passport/ID number, driving licence details.</li>
  <li><strong>Contact data:</strong> Email address, phone number, postal address.</li>
  <li><strong>Financial data:</strong> Payment card details, bank account information.</li>
  <li><strong>Transaction data:</strong> Rental history, booking details, invoice records.</li>
  <li><strong>Technical data:</strong> IP address, browser type, cookies.</li>
</ul>

<h2>3. Legal Basis for Processing</h2>
<p>We process your personal data on the following legal bases: performance of a contract, compliance with a legal obligation, and legitimate interests.</p>

<h2>4. Contact</h2>
<p>For privacy-related enquiries, contact us at [EMAIL].</p>''',
    ),
    PageItem(
      id: 7,
      title: 'Cookie Policy',
      slug: 'cookie',
      content: '''<h1>Cookie Policy</h1>
<p><strong>Welrent AutoVerhuur</strong><br>
Email: [EMAIL]<br>
<em>Last updated: 2025</em></p>

<hr>

<h2>1. What Are Cookies?</h2>
<p>Cookies are small text files placed on your device when you visit our website. They help us provide a better, more personalised experience.</p>

<h2>2. Cookies We Use</h2>
<h3>Strictly Necessary Cookies</h3>
<p>These cookies are essential for the website to function correctly. They enable session management, security, and accessibility.</p>

<h3>Analytics Cookies</h3>
<p>We use analytics cookies to understand how visitors interact with our platform.</p>

<h2>3. Contact</h2>
<p>For questions about our use of cookies, contact us at [EMAIL].</p>''',
    ),
    PageItem(
      id: 8,
      title: 'Accessibility Statement',
      slug: 'accessibility',
      content: '''<h1>Accessibility Statement</h1>
<p><strong>Welrent AutoVerhuur</strong><br>
Email: [EMAIL]<br>
<em>Last updated: 2025</em></p>

<hr>

<h2>Our Commitment</h2>
<p>Welrent AutoVerhuur is committed to ensuring digital accessibility for people with disabilities. We continually improve the user experience for everyone and apply relevant accessibility standards.</p>

<h2>Feedback</h2>
<p>We welcome your feedback on the accessibility of Welrent Act. Please contact us at [EMAIL].</p>''',
    ),
  ];

  static final List<Contract> contracts = [
    Contract(
      id: 1,
      contractRef: 'ACT-WLR-2026-DEMO1',
      bookingRef: 'WLR-2026-DEMO1',
      userUid: 'demo-user-001',
      userEmail: 'demo@welrent.com',
      userName: 'Demo Renter',
      vehicleType: 'car',
      vehicleName: 'Audi RS6 Avant',
      vehicleImage: 'assets/img/hero_car.png',
      startDate: DateTime(2026, 8, 20),
      endDate: DateTime(2026, 8, 22),
      days: 2,
      price: 380.0,
      location: 'Amsterdam Central',
      status: 'active',
      agreementSlug: 'car-rental-agreement',
      contractHtml: '''<article class="legal-document rental-contract">
  <h1>Welrent Rental Contract</h1>
  <p class="legal-meta">
    <strong>Contract:</strong> ACT-WLR-2026-DEMO1<br>
    <strong>Booking:</strong> WLR-2026-DEMO1<br>
    <strong>Generated by:</strong> Welrent Act<br>
    <em>Created automatically from the Welrent booking platform</em>
  </p>
  <hr>
  <h2>Parties</h2>
  <p><strong>Lessor:</strong> Welrent AutoVerhuur</p>
  <p><strong>Renter:</strong> Demo Renter &lt;demo@welrent.com&gt;</p>
  <h2>Vehicle</h2>
  <ul>
    <li><strong>Type:</strong> car</li>
    <li><strong>Vehicle:</strong> Audi RS6 Avant</li>
    <li><strong>Location:</strong> Amsterdam Central</li>
  </ul>
  <h2>Rental Period</h2>
  <ul>
    <li><strong>Start:</strong> 2026-08-20</li>
    <li><strong>End:</strong> 2026-08-22</li>
    <li><strong>Days:</strong> 2</li>
    <li><strong>Price:</strong> €380.00</li>
  </ul>
  <p>This contract incorporates the standard terms published at
    <a href="/pages/car-rental-agreement">/pages/car-rental-agreement</a>.
  </p>
</article>''',
    ),
    Contract(
      id: 2,
      contractRef: 'ACT-WLR-2026-DEMO2',
      bookingRef: 'WLR-2026-DEMO2',
      userUid: 'demo-user-001',
      userEmail: 'demo@welrent.com',
      userName: 'Demo Renter',
      vehicleType: 'motorcycle',
      vehicleName: 'Yamaha MT-07',
      startDate: DateTime(2026, 9, 1),
      endDate: DateTime(2026, 9, 3),
      days: 2,
      price: 160.0,
      location: 'Rotterdam Centrum',
      status: 'active',
      agreementSlug: 'motorcycle-rental-agreement',
      contractHtml: '''<article class="legal-document rental-contract">
  <h1>Welrent Rental Contract</h1>
  <p class="legal-meta">
    <strong>Contract:</strong> ACT-WLR-2026-DEMO2<br>
    <strong>Booking:</strong> WLR-2026-DEMO2<br>
    <strong>Generated by:</strong> Welrent Act<br>
    <em>Created automatically from the Welrent booking platform</em>
  </p>
  <hr>
  <h2>Parties</h2>
  <p><strong>Lessor:</strong> Welrent AutoVerhuur</p>
  <p><strong>Renter:</strong> Demo Renter &lt;demo@welrent.com&gt;</p>
  <h2>Vehicle</h2>
  <ul>
    <li><strong>Type:</strong> motorcycle</li>
    <li><strong>Vehicle:</strong> Yamaha MT-07</li>
    <li><strong>Location:</strong> Rotterdam Centrum</li>
  </ul>
  <h2>Rental Period</h2>
  <ul>
    <li><strong>Start:</strong> 2026-09-01</li>
    <li><strong>End:</strong> 2026-09-03</li>
    <li><strong>Days:</strong> 2</li>
    <li><strong>Price:</strong> €160.00</li>
  </ul>
  <p>This contract incorporates the standard terms published at
    <a href="/pages/motorcycle-rental-agreement">/pages/motorcycle-rental-agreement</a>.
  </p>
</article>''',
    ),
  ];

  static final List<SiteSetting> settings = [
    SiteSetting(
        key: 'COMPANY_ADDRESS', value: 'Welrent AutoVerhuur, The Netherlands'),
    SiteSetting(key: 'CHAMBER_OF_COMMERCE_NUMBER', value: 'KVK pending'),
    SiteSetting(key: 'VAT_NUMBER', value: 'NL VAT pending'),
    SiteSetting(key: 'EMAIL', value: 'hello@welrent.com'),
    SiteSetting(key: 'PHONE_NUMBER', value: '+31 (0)20 000 0000'),
  ];
}
